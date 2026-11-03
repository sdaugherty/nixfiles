{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.myConfig.modules.pin_auth_desktop;

  # PAM module and helper tools for PIN authentication with failure limit
  pamPinAuth = pkgs.stdenv.mkDerivation {
    pname = "pam-pin-auth";
    version = "1.0.0";

    dontUnpack = true;

    buildInputs = [
      pkgs.pam
      pkgs.libxcrypt
    ];

    pamPinSource = pkgs.writeText "pam_pin.c" ''
      #define _GNU_SOURCE
      #include <security/pam_modules.h>
      #include <security/pam_ext.h>
      #include <security/pam_modutil.h>
      #include <sys/stat.h>
      #include <sys/wait.h>
      #include <fcntl.h>
      #include <unistd.h>
      #include <stdio.h>
      #include <stdlib.h>
      #include <string.h>
      #include <ctype.h>
      #include <syslog.h>

      #define HELPER_PATH "/run/wrappers/bin/pin_chkpwd"

      static int is_valid_username(const char *u) {
          if (!u || !*u || strlen(u) > 64) return 0;
          if (u[0] == '.' || u[0] == '-') return 0;
          for (const char *p = u; *p; p++) {
              if (!isalnum((unsigned char)*p) && *p != '_' && *p != '-' && *p != '.') {
                  return 0;
              }
          }
          return 1;
      }

      static int run_helper(const char *action, const char *user, const char *max_tries, const char *token) {
          int pipefd[2];
          if (token) {
              if (pipe(pipefd) != 0) return PAM_SYSTEM_ERR;
          }

          pid_t pid = fork();
          if (pid < 0) {
              if (token) {
                  close(pipefd[0]);
                  close(pipefd[1]);
              }
              return PAM_SYSTEM_ERR;
          }

          if (pid == 0) {
              if (token) {
                  close(pipefd[1]);
                  if (dup2(pipefd[0], STDIN_FILENO) < 0) _exit(PAM_SYSTEM_ERR);
                  close(pipefd[0]);
              } else {
                  int devnull = open("/dev/null", O_RDONLY);
                  if (devnull >= 0) {
                      dup2(devnull, STDIN_FILENO);
                      close(devnull);
                  }
              }
              char *const args[] = { (char *)HELPER_PATH, (char *)action, (char *)user, (char *)max_tries, NULL };
              char *const envp[] = { NULL };
              execve(HELPER_PATH, args, envp);
              _exit(PAM_SYSTEM_ERR);
          }

          if (token) {
              close(pipefd[0]);
              size_t len = strlen(token);
              ssize_t written = write(pipefd[1], token, len);
              (void)written;
              close(pipefd[1]);
          }

          int status = 0;
          if (waitpid(pid, &status, 0) < 0) {
              return PAM_SYSTEM_ERR;
          }
          if (WIFEXITED(status)) {
              return WEXITSTATUS(status);
          }
          return PAM_SYSTEM_ERR;
      }

      PAM_EXTERN int pam_sm_authenticate(pam_handle_t *pamh, int flags, int argc, const char **argv) {
          (void)flags;
          const char *action = "verify";
          const char *max_tries = "${toString cfg.maxAttempts}";

          for (int i = 0; i < argc; i++) {
              if (strcmp(argv[i], "reset") == 0) {
                  action = "reset";
              } else if (strncmp(argv[i], "max_tries=", 10) == 0) {
                  max_tries = argv[i] + 10;
              }
          }

          const char *user = NULL;
          int ret = pam_get_user(pamh, &user, NULL);
          if (ret != PAM_SUCCESS || !is_valid_username(user)) {
              return PAM_USER_UNKNOWN;
          }

          if (strcmp(action, "reset") == 0) {
              run_helper("reset", user, max_tries, NULL);
              return PAM_SUCCESS;
          }

          /* Pre-check if user has a PIN configured before prompting */
          int check_rc = run_helper("check", user, max_tries, NULL);
          if (check_rc != 0) {
              return PAM_IGNORE;
          }

          const char *authtok = NULL;
          ret = pam_get_authtok(pamh, PAM_AUTHTOK, &authtok, NULL);
          if (ret != PAM_SUCCESS || !authtok) {
              return PAM_IGNORE;
          }

          int verify_rc = run_helper("verify", user, max_tries, authtok);
          if (verify_rc == 0) {
              return PAM_SUCCESS;
          }
          return PAM_IGNORE;
      }

      PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc, const char **argv) {
          (void)pamh; (void)flags; (void)argc; (void)argv;
          return PAM_SUCCESS;
      }

      PAM_EXTERN int pam_sm_acct_mgmt(pam_handle_t *pamh, int flags, int argc, const char **argv) {
          (void)pamh; (void)flags; (void)argc; (void)argv;
          return PAM_SUCCESS;
      }
    '';

    pinChkpwdSource = pkgs.writeText "pin_chkpwd.c" ''
      #define _GNU_SOURCE
      #include <sys/stat.h>
      #include <sys/file.h>
      #include <fcntl.h>
      #include <unistd.h>
      #include <pwd.h>
      #include <stdio.h>
      #include <stdlib.h>
      #include <string.h>
      #include <ctype.h>
      #include <crypt.h>
      #include <syslog.h>

      #define PIN_DIR "/etc/security/pins"
      #define TALLY_DIR "/run/pam_pin_tally"

      static int is_valid_username(const char *u) {
          if (!u || !*u || strlen(u) > 64) return 0;
          if (u[0] == '.' || u[0] == '-') return 0;
          for (const char *p = u; *p; p++) {
              if (!isalnum((unsigned char)*p) && *p != '_' && *p != '-' && *p != '.') {
                  return 0;
              }
          }
          return 1;
      }

      /* Prevent unprivileged users from probing or resetting another user's PIN */
      static int check_caller_authorized(const char *user) {
          uid_t ruid = getuid();
          if (ruid == 0) return 1;
          struct passwd *pw = getpwnam(user);
          if (!pw) return 0;
          return (pw->pw_uid == ruid);
      }

      static int ensure_tally_dir(void) {
          struct stat st;
          if (stat(TALLY_DIR, &st) != 0) {
              if (mkdir(TALLY_DIR, 0700) != 0) return -1;
          }
          return 0;
      }

      int main(int argc, char **argv) {
          if (argc < 4) return 2;
          const char *action = argv[1];
          const char *user = argv[2];
          int max_tries = atoi(argv[3]);
          if (max_tries <= 0) max_tries = 3;

          if (!is_valid_username(user)) return 2;
          if (!check_caller_authorized(user)) return 2;

          char pin_path[256];
          char tally_path[256];
          snprintf(pin_path, sizeof(pin_path), "%s/%s", PIN_DIR, user);
          snprintf(tally_path, sizeof(tally_path), "%s/%s", TALLY_DIR, user);

          if (strcmp(action, "reset") == 0) {
              unlink(tally_path);
              return 0;
          }

          struct stat st;
          if (stat(pin_path, &st) != 0 || !S_ISREG(st.st_mode)) {
              return 1; /* No PIN configured for user */
          }

          if (strcmp(action, "check") == 0) {
              return 0;
          }

          if (strcmp(action, "verify") != 0) {
              return 2;
          }

          /* Read candidate token from stdin */
          char token[512];
          ssize_t n = read(STDIN_FILENO, token, sizeof(token) - 1);
          if (n <= 0) {
              return 1;
          }
          token[n] = '\0';
          while (n > 0 && (token[n - 1] == '\n' || token[n - 1] == '\r')) {
              token[--n] = '\0';
          }
          if (n == 0) {
              memset(token, 0, sizeof(token));
              return 1;
          }

          if (ensure_tally_dir() != 0) {
              memset(token, 0, sizeof(token));
              return 2;
          }

          int tfd = open(tally_path, O_RDWR | O_CREAT | O_NOFOLLOW, 0600);
          if (tfd < 0) {
              memset(token, 0, sizeof(token));
              return 2;
          }
          flock(tfd, LOCK_EX);

          int fails = 0;
          char tbuf[32] = {0};
          if (read(tfd, tbuf, sizeof(tbuf) - 1) > 0) {
              fails = atoi(tbuf);
          }

          /* If failed attempts reached max_tries, reject PIN and require full password */
          if (fails >= max_tries) {
              flock(tfd, LOCK_UN);
              close(tfd);
              memset(token, 0, sizeof(token));
              return 1;
          }

          /* Read stored PIN hash */
          FILE *pf = fopen(pin_path, "r");
          if (!pf) {
              flock(tfd, LOCK_UN);
              close(tfd);
              memset(token, 0, sizeof(token));
              return 1;
          }
          char hash[512] = {0};
          if (!fgets(hash, sizeof(hash), pf)) {
              fclose(pf);
              flock(tfd, LOCK_UN);
              close(tfd);
              memset(token, 0, sizeof(token));
              return 1;
          }
          fclose(pf);
          size_t hlen = strlen(hash);
          while (hlen > 0 && (hash[hlen - 1] == '\n' || hash[hlen - 1] == '\r')) {
              hash[--hlen] = '\0';
          }

          struct crypt_data cd;
          memset(&cd, 0, sizeof(cd));
          char *computed = crypt_r(token, hash, &cd);
          memset(token, 0, sizeof(token));

          if (computed && strcmp(computed, hash) == 0) {
              /* Valid PIN: clear failure counter */
              ftruncate(tfd, 0);
              lseek(tfd, 0, SEEK_SET);
              dprintf(tfd, "0\n");
              flock(tfd, LOCK_UN);
              close(tfd);
              memset(&cd, 0, sizeof(cd));
              return 0;
          }

          /* Invalid PIN (or user entered their full password): increment PIN failure counter */
          fails++;
          ftruncate(tfd, 0);
          lseek(tfd, 0, SEEK_SET);
          dprintf(tfd, "%d\n", fails);
          flock(tfd, LOCK_UN);
          close(tfd);
          memset(&cd, 0, sizeof(cd));

          openlog("pam_pin", LOG_PID, LOG_AUTHPRIV);
          if (fails >= max_tries) {
              syslog(LOG_NOTICE, "PIN locked out for user %s after %d failed attempts; full password required", user, fails);
          } else {
              syslog(LOG_INFO, "PIN check did not match for user %s (attempt %d/%d)", user, fails, max_tries);
          }
          closelog();

          return 1;
      }
    '';

    setPinScript = pkgs.writeShellScript "set-pin" ''
      set -euo pipefail

      if [ "''${EUID:-$(id -u)}" -ne 0 ]; then
        exec sudo "$0" "$@"
      fi

      usage() {
        echo "Usage:"
        echo "  set-pin [username]           Set or update PIN for a user (defaults to calling user)"
        echo "  set-pin --remove [username]  Remove PIN for a user"
        echo "  set-pin --status [username]  Show PIN status and failed attempt counter"
        echo "  set-pin --unlock [username]  Reset failed PIN attempt counter"
      }

      ACTION="set"
      if [ $# -ge 1 ]; then
        case "$1" in
          --remove|-r)
            ACTION="remove"
            shift
            ;;
          --status|-s)
            ACTION="status"
            shift
            ;;
          --unlock|-u)
            ACTION="unlock"
            shift
            ;;
          --help|-h)
            usage
            exit 0
            ;;
        esac
      fi

      TARGET_USER="''${1:-''${SUDO_USER:-$(logname 2>/dev/null || echo root)}}"

      if ! id "$TARGET_USER" >/dev/null 2>&1; then
        echo "Error: User '$TARGET_USER' does not exist." >&2
        exit 1
      fi

      PIN_DIR="/etc/security/pins"
      PIN_FILE="$PIN_DIR/$TARGET_USER"
      TALLY_FILE="/run/pam_pin_tally/$TARGET_USER"

      mkdir -p -m 0700 "$PIN_DIR"
      chown root:root "$PIN_DIR"

      case "$ACTION" in
        remove)
          rm -f "$PIN_FILE" "$TALLY_FILE"
          echo "PIN removed for user '$TARGET_USER'."
          ;;
        unlock)
          rm -f "$TALLY_FILE"
          echo "PIN failure counter reset for user '$TARGET_USER'."
          ;;
        status)
          if [ -f "$PIN_FILE" ]; then
            echo "PIN status for '$TARGET_USER': Configured"
          else
            echo "PIN status for '$TARGET_USER': Not configured"
          fi
          FAILS=0
          if [ -f "$TALLY_FILE" ]; then
            FAILS=$(cat "$TALLY_FILE" 2>/dev/null || echo 0)
          fi
          echo "Failed attempts: $FAILS / ${toString cfg.maxAttempts}"
          if [ "$FAILS" -ge ${toString cfg.maxAttempts} ]; then
            echo "State: LOCKED (full password required to authenticate and reset PIN counter)"
          else
            echo "State: Active"
          fi
          ;;
        set)
          read -r -s -p "Enter new PIN for $TARGET_USER: " PIN1
          echo >&2
          read -r -s -p "Confirm new PIN for $TARGET_USER: " PIN2
          echo >&2

          if [ -z "$PIN1" ]; then
            echo "Error: PIN cannot be empty." >&2
            exit 1
          fi

          if [ "$PIN1" != "$PIN2" ]; then
            echo "Error: PINs do not match." >&2
            exit 1
          fi

          HASH=$(printf '%s\n' "$PIN1" | ${pkgs.mkpasswd}/bin/mkpasswd -m yescrypt -s)
          umask 0077
          printf '%s\n' "$HASH" > "$PIN_FILE.tmp"
          chown root:root "$PIN_FILE.tmp"
          chmod 0600 "$PIN_FILE.tmp"
          mv "$PIN_FILE.tmp" "$PIN_FILE"
          rm -f "$TALLY_FILE"
          echo "PIN successfully set for '$TARGET_USER'."
          ;;
      esac
    '';

    buildPhase = ''
      mkdir -p $out/lib/security $out/bin
      $CC -shared -fPIC -O2 -Wall -Wextra $pamPinSource -o $out/lib/security/pam_pin.so -lpam
      $CC -O2 -Wall -Wextra $pinChkpwdSource -o $out/bin/pin_chkpwd -lcrypt
      cp $setPinScript $out/bin/set-pin
      chmod +x $out/bin/set-pin
    '';

    dontInstall = true;
  };

  # Helper to attach PIN authentication and password-reset rules to a PAM service
  mkPinPamService =
    serviceName:
    let
      svcCfg = config.security.pam.services.${serviceName};
      # When KWallet or similar early modules are enabled, NixOS runs `unix-early`
      # before `unix` to capture PAM_AUTHTOK. Place `pin_auth` before `unix-early`
      # when present so the single prompt accepts either PIN or password cleanly.
      hasUnixEarly =
        (svcCfg.rules.auth ? unix-early) && svcCfg.rules.auth.unix-early.enable;
      firstUnixOrder =
        if hasUnixEarly then
          svcCfg.rules.auth.unix-early.order
        else
          svcCfg.rules.auth.unix.order;
    in
    {
      rules.auth = {
        pin_auth = {
          enable = true;
          order = firstUnixOrder - 100;
          control = "sufficient";
          modulePath = "${pamPinAuth}/lib/security/pam_pin.so";
          args = [ "max_tries=${toString cfg.maxAttempts}" ];
        };
        # Placed immediately after `unix` (which uses `control = "[success=ok default=1]"`
        # so that a failed password skips `pin_reset`, whereas a valid password runs `pin_reset`
        # to clear any PIN lockout and then succeeds via `pin_Reset`'s `sufficient` control).
        unix.control = lib.mkForce "[success=ok default=1]";
        pin_reset = {
          enable = true;
          order = svcCfg.rules.auth.unix.order + 10;
          control = "sufficient";
          modulePath = "${pamPinAuth}/lib/security/pam_pin.so";
          args = [ "reset" ];
        };
      };
    };
in
{
  options.myConfig.modules.pin_auth_desktop = {
    enable = lib.mkEnableOption "PIN authentication with password fallback for desktop and sudo";

    maxAttempts = lib.mkOption {
      type = lib.types.ints.positive;
      default = 3;
      description = "Maximum number of failed PIN attempts before requiring the full password.";
    };

    services = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "login"
        "kde"
        "sudo"
        "polkit-1"
      ];
      description = ''
        PAM services to enable PIN authentication on.
        Note: SDDM uses `auth substack login`, so enabling `login` covers SDDM desktop login.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pamPinAuth ];

    security.wrappers.pin_chkpwd = {
      source = "${pamPinAuth}/bin/pin_chkpwd";
      owner = "root";
      group = "root";
      setuid = true;
    };

    systemd.tmpfiles.rules = [
      "d /etc/security/pins 0700 root root -"
      "d /run/pam_pin_tally 0700 root root -"
    ];

    security.pam.services = lib.genAttrs cfg.services mkPinPamService;
  };
}
