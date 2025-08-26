# Zuksh's HTTPX Status Code Extractor

A powerful Bash script crafted by **Zuksh** to extract domains with specific HTTP status codes (200, 301, 403, 404) using the `httpx` tool. This tool supports concurrent processing, retry handling, text/JSON output formats, and detailed reporting, making it ideal for web reconnaissance and security testing.

## Features
- **Custom Banner**: Displays a personalized banner with Zuksh's name.
- **Status Code Extraction**: Filters domains by HTTP status codes 200, 301, 403, and 404.
- **Concurrent Processing**: Uses multiple threads for fast scanning.
- **Retry Mechanism**: Retries failed requests for reliability.
- **Output Formats**: Supports text (`txt`) and JSON (`json`) output.
- **Metadata**: Includes page titles and detected technologies in results.
- **Configuration File**: Customizable `httpx` settings via `httpx.conf`.
- **Error Logging**: Logs errors to a dedicated file.
- **Summary Report**: Generates a detailed summary of results.

## Prerequisites
- **httpx**: A fast HTTP probing tool from ProjectDiscovery.
- **jq**: Required for JSON output processing.
- **Bash**: Compatible with Linux/macOS.

## Installation
1. **Install httpx**:
   ```bash
   go install -v https://github.com/zukksh/zuksh-httpx-extractor
   ```
   Ensure `$GOPATH/bin` is in your `$PATH`.

2. **Install jq**:
   - Ubuntu/Debian: `sudo apt-get install jq`
   - macOS: `brew install jq`
   - CentOS/RHEL: `sudo yum install jq`

3. **Clone the Repository**:
   ```bash
   git clone https://github.com/zeyadR3/zuksh-httpx-extractor
   cd zuksh-httpx-extractor
   ```

4. **Make the Script Executable**:
   ```bash
   chmod +x zuksh_httpx_extractor.sh
   ```

## Usage
```bash
./zuksh_httpx_extractor.sh <domains_file> [-o <output_format>] [-c <config_file>]
```
- `<domains_file>`: Text file with one domain per line.
- `-o <output_format>`: Output format (`txt` or `json`, default: `txt`).
- `-c <config_file>`: Configuration file for `httpx` settings (e.g., `httpx.conf`).

### Examples
1. **Basic Usage**:
   ```bash
   ./zuksh_httpx_extractor.sh domains.txt
   ```
   Processes `domains.txt` and saves results in text format.

2. **JSON Output**:
   ```bash
   ./zuksh_httpx_extractor.sh domains.txt -o json
   ```
   Saves results in JSON format.

3. **Custom Configuration**:
   ```bash
   ./zuksh_httpx_extractor.sh domains.txt -o txt -c httpx.conf
   ```
   Uses settings from `httpx.conf`.

### Sample Domains File
Create `domains.txt` with:
```
mta-sts.hackerone.com
docs.hackerone.com
www.hackerone.com
support.hackerone.com
```

### Sample Configuration File
Edit `httpx.conf` to customize settings:
```
# Number of concurrent threads
THREADS=200

# Timeout for each request (in seconds)
TIMEOUT=15

# Number of retries for failed requests
RETRIES=3
```

## Output
Results are saved in a timestamped directory (e.g., `zuksh_httpx_results_20250504_123456`):
- `domains_<status>.txt` or `domains_<status>.json`: Results for each status code.
- `error.log`: Logs any `httpx` errors.
- `summary.txt`: Summary of the scan.

### Example Output
```
=========================================
    Zuksh's HTTPX Status Code Extractor
=========================================
  Crafted by: Zuksh
  Version: 1.0
  Purpose: Extract domains by HTTP status
=========================================

Total domains to process: 4
Processing status code 200...
Results saved to zuksh_httpx_results_20250504_123456/domains_200.txt
Found 2 domains with status 200
...
Processing complete. Summary saved to zuksh_httpx_results_20250504_123456/summary.txt
Thank you for using Zuksh's HTTPX Extractor!
```

## Contributing
Contributions are welcome! Please submit a pull request or open an issue on GitHub.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact
For questions or feedback, contact Zuksh via GitHub issues.

---

Crafted with 💻 by Zuksh
