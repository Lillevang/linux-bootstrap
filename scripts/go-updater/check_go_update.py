import sys
import requests
import re
from bs4 import BeautifulSoup
from packaging.version import parse

GO_URL = 'https://go.dev/'

class Release:
    def __init__(self, version, download_link, checksum):
        self.version = version
        self.download_link = download_link
        self.checksum = checksum
        self.os = 'linux'

    def __str__(self):
        return f'{self.version} {self.download_link} {self.checksum}'

    def __repr__(self):
        return f'{self.version} {self.download_link} {self.checksum}'

def fetch_download_page():
    response = requests.get(f'{GO_URL}/dl/')
    if response.status_code != 200:
        print('Failed to fetch download page')
        sys.exit(1)
    return response.text

def parse_version_from_filename(file_name):
    # regex to fetch the version from a filename like: go1.22.1.linux-amd64.tar.gz
    pattern = r"(\d+\.\d+\.\d+)"
    match = re.search(pattern, file_name)
    if match:
        return match.group(1)
    return None

def get_release(page):
    soup = BeautifulSoup(page, 'html.parser')
    download_table = soup.find('table', class_='downloadtable')

    for row in download_table.find_all('tr')[1:]:
        cols = row.find_all('td')
        file_name = cols[0].text
        os = cols[2].text
        arch = cols[3].text
        checksum = cols[5].text
        if os == 'Linux' and arch == 'x86-64':
            version = parse_version_from_filename(file_name)
            download_link = f'{GO_URL}dl/{file_name}'
            return Release(version, download_link, checksum)

def main():
    if len(sys.argv) < 2:
        print('Usage: downloader.py <installed_version>')
        sys.exit(1)
    installed_version = sys.argv[1]
    release = get_release(fetch_download_page())

    # if the installed version is less than the latest version
    if parse(installed_version) < parse(release.version):        
        print(release)
    sys.exit(0)

if __name__ == '__main__':
    main()
