# Simple Telnet Server using PowerShell

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, 8080)

$listener.Start()

Write-Host "Listening for incoming connections on port 8080..."

while ($true) {
    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()
    $reader = [System.IO.StreamReader]::new($stream)
    $writer = [System.IO.StreamWriter]::new($stream)

    $writer.WriteLine("Welcome to PowerShell Telnet Server")
    $writer.Flush()

    while ($client.Connected) {
        $command = $reader.ReadLine()
        if ($command -eq $null) {
            break
        }

        $output = Invoke-Expression $command 2>&1
        $writer.WriteLine($output)
        $writer.Flush()
    }

    $client.Close()
}

$listener.Stop()
