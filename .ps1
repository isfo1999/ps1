# Set the port to listen on
$port = 8080

# Create a TcpListener object to listen for incoming connections
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $port)

# Start listening for incoming connections
$listener.Start()

Write-Host "Listening for connections on port $port..."

# Infinite loop to keep listening for connections
while ($true) {
    # Accept a pending connection
    $client = $listener.AcceptTcpClient()

    Write-Host "Connection accepted from $($client.Client.RemoteEndPoint)"

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

    # Print the headers
    Write-Host "Headers from $($client.Client.RemoteEndPoint):"
    Write-Host $headers

    # Close the connection
    $client.Close()
}
