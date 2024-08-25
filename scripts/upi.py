from bs4 import BeautifulSoup

def extract_phonepe_data(html_file):
    with open(html_file, 'r', encoding='utf-8') as file:
        html_content = file.read()
    
    # Parse the HTML content
    soup = BeautifulSoup(html_content, 'html.parser')
    tables = soup.find_all('table')
    
    # Initialize a list to hold the extracted data
    phonepe_data = []
    
    # Iterate through the tables to find the relevant data
    for table in tables:
        rows = table.find_all('tr')
        for row in rows:
            cells = row.find_all(['td', 'th'])
            cells_text = [cell.get_text(strip=True) for cell in cells]
            if len(cells_text) > 1 and "PhonePe" in cells_text[1]:
                # Add None for missing columns to ensure uniform length
                while len(cells_text) < 10:
                    cells_text.append(None)
                phonepe_data.append(cells_text)
    
    # Format the output as a table
    headers = ["Month/Year", "Application Name", "Customer Initiated Transactions (Volume in Mn)", 
               "Customer Initiated Transactions (Value in Cr)", "B2C Transactions (Volume in Mn)", 
               "B2C Transactions (Value in Cr)", "B2B Transactions (Volume in Mn)", 
               "B2B Transactions (Value in Cr)", "Total Volume (Mn)", "Total Value (Cr)"]
    
    print(f"{headers[0]:<12} {headers[1]:<15} {headers[2]:<45} {headers[3]:<45} {headers[4]:<40} {headers[5]:<40} {headers[6]:<40} {headers[7]:<40} {headers[8]:<20} {headers[9]:<20}")
    for data in phonepe_data:
        # Handle missing data gracefully
        print(f"{data[0]:<12} {data[1]:<15} {data[2]:<45} {data[3]:<45} {data[4]:<40} {data[5]:<40} {data[6]:<40} {data[7]:<40} {data[8]:<20} {data[9]:<20}")

# Usage
html_file = '/Users/anshu.prateek/tmp/upi/upi.html'
extract_phonepe_data(html_file)
