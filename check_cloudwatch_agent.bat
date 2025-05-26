@echo off

echo Fetching EC2 public IPs from Terraform output...

REM PowerShellでJSON→配列→個別にループ
for /f "usebackq delims=" %%a in (`powershell -Command "terraform output -json instance_public_ips | ConvertFrom-Json | ForEach-Object { $_ }"`) do (
    echo.
    echo ==== Checking instance at IP: %%a ====
    ssh -o StrictHostKeyChecking=no -i "C:\Users\446435760\.ssh\id_ed25519" ec2-user@%%a "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status"

    ssh -o StrictHostKeyChecking=no -i "C:\Users\446435760\.ssh\id_ed25519" ec2-user@%%a "sudo tail -n 20 /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
)

echo.
echo All instances checked.
pause
