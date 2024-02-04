# Function to get the public IP address using an external service
function Get-PublicIpAddress {
    $ipAddress = (Invoke-RestMethod -Uri "https://api64.ipify.org?format=json").ip
    return $ipAddress
}

# Set the port to listen on
$port = 8080

# Create a TcpListener object to listen for incoming connections
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)

# Start listening for incoming connections
$listener.Start()

# Get the public IP address
$publicIpAddress = Get-PublicIpAddress

Write-Host "Listening for connections on $publicIpAddress:$port..."

# Infinite loop to keep listening for connections
while ($true) {
    # Accept a pending connection
    $client = $listener.AcceptTcpClient()

    $clientAddress = $client.Client.RemoteEndPoint
    Write-Host "Connection accepted from $clientAddress"

    # Get the network stream for reading/writing data
    $stream = $client.GetStream()
    $reader = [System.IO.StreamReader]::new($stream)
    
    # Read the headers from the client
    $headers = ""
    while ($true) {
        $line = $reader.ReadLine()
        if ([string]::IsNullOrEmpty($line)) {
            break
        }
        $headers += $line + "`r`n"
    }

    # Print the listening, public, and connected addresses
    Write-Host "Listening on: $publicIpAddress:$port"
    Write-Host "Public IP address: $publicIpAddress"
    Write-Host "Connected to: $clientAddress"

    # Print the headers
    Write-Host "Headers from $clientAddress:"
    Write-Host $headers

    # Close the connection
    $client.Close()
}
