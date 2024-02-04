$listener = New-Object System.Net.Sockets.TcpListener ([System.Net.IPAddress]::Any, 8080)
$listener.start()

Write-Host "Listening for connections on port 8080..."

while ($true) {
    if ($listener.Pending()) {
        $client = $listener.AcceptTcpClient()
        Write-Host "Client connected: $($client.Client.RemoteEndPoint)"

        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $writer = New-Object System.IO.StreamWriter($stream)

        while ($client.Connected) {
            $data = $reader.ReadLine()
            if ($data -eq $null) {
                break
            }

            Write-Host "Received: $data"

            # Add your custom logic here to process the received data

            # Echo back to the client
            $writer.WriteLine(">")
            &$data
            $writer.Flush()
        }

        Write-Host "Client disconnected: $($client.Client.RemoteEndPoint)"
        $client.Close()
    }

    Start-Sleep -Seconds 1
}

$listener.Stop()
