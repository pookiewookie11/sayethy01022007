$root = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:8001/"
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Host "Serving $root at $prefix (press Ctrl+C in this terminal to stop)"
try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $req = $context.Request
        $resp = $context.Response
        $rel = $req.Url.AbsolutePath.TrimStart('/')
        if ($rel -eq '') { $rel = 'index.html' }
        $file = Join-Path $root $rel
        if (Test-Path $file) {
            $ext = [IO.Path]::GetExtension($file).ToLower()
            switch ($ext) {
                '.html' { $ctype='text/html' }
                '.htm' { $ctype='text/html' }
                '.css' { $ctype='text/css' }
                '.js' { $ctype='application/javascript' }
                '.json' { $ctype='application/json' }
                '.png' { $ctype='image/png' }
                '.jpg' { $ctype='image/jpeg' }
                '.jpeg' { $ctype='image/jpeg' }
                '.gif' { $ctype='image/gif' }
                '.svg' { $ctype='image/svg+xml' }
                default { $ctype='application/octet-stream' }
            }
            $bytes = [System.IO.File]::ReadAllBytes($file)
            $resp.ContentType = $ctype
            $resp.ContentLength64 = $bytes.Length
            $resp.OutputStream.Write($bytes,0,$bytes.Length)
        } else {
            $resp.StatusCode = 404
            $msg = "404 Not Found"
            $buf = [System.Text.Encoding]::UTF8.GetBytes($msg)
            $resp.ContentType = 'text/plain'
            $resp.ContentLength64 = $buf.Length
            $resp.OutputStream.Write($buf,0,$buf.Length)
        }
        $resp.Close()
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
