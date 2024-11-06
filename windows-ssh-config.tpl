add-content -path C:/Users/sande/.ssh/config -value @'

Host $(hostname)
  HostName $(hostname)
  User $(USER)
  IdentityFile $(identityfile)
'@