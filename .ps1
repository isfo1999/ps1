# Simple Telnet Server using PowerShell

$listener = New-Object System.Net.Sockets.TcpListener (IPAddress::Any, 8080)

$listener.Start()

Write-Host "Listening for incoming connections on port 8080..."

while ($true) {
    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader $stream
    $writer = New-Object System.IO.StreamWriter $stream

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
