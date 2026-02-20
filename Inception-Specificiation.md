# Project Specification

## Success Criteria
The project is successful when all services are fully functional via a container orchestration setup, featuring secure networking, automated recovery, and robust secret management.

---

## Part 1: Must-Haves

### Service Architecture
| Service | Image/Type | Key Requirements |
| :--- | :--- | :--- |
| **Database** | MariaDB | • Port `3306` connection to PHP-FPM.<br>• Data persistence via volume stored in `/home/login/data/wordpressdb`.<br>• Two users required in the WordPress database (one must be the Admin). |
| **Application** | WordPress-PHP-FPM | • Port `3306` (MariaDB) and Port `9000` (Nginx).<br>• Files persistence via volume stored in `/home/login/data/wordpressfiles`.<br>• Admin username cannot contain "admin" or similar. |
| **Web Server** | Nginx | • Only entry point via Port `443`.<br>• Enforced TLS v1.2 or v1.3.<br>• Access to shared `wordpressfiles` volume. |

### Networking and restart policy
*   **Isolation:** Use custom network/s. **Prohibited:** `host` mode, `--link`, or `links:`.
*   **Resilience:** All containers must have a restart policy (e.g., `on-failure` or `always`) to handle crashes.

### Configuration
*   **Secret Management:** Mandatory use of **Docker Secrets** for sensitive data.
*   **Environment Variables:** Mandatory `.env` file for non-sensitive configuration.
*   **Git Integrity:** No credentials, passwords, or secrets may be hardcoded in Dockerfiles or committed to the repository.

---

## Part 2: Nice-to-have
