raise if not node[:platform] == 'windows'

powershell "register_services" do
  code <<-EOH
    if (-not (Get-Service "#{node[:service][:nova][:name]}" -ErrorAction SilentlyContinue))
    {
      New-Service -name "#{node[:service][:nova][:name]}" -binaryPathName "`"#{node[:openstack][:bin]}\\#{node[:service][:file]}`" nova-compute `"#{node[:openstack][:nova][:installed]}`" --config-file `"#{node[:openstack][:config]}\\nova.conf`"" -displayName "#{node[:service][:nova][:displayname]}" -description "#{node[:service][:nova][:description]}" -startupType Automatic
      Start-Service "#{node[:service][:nova][:name]}"
      Set-Service -Name "#{node[:service][:nova][:name]}" -StartupType Automatic
    }
  EOH
end

service "nova-compute" do
  service_name node[:service][:nova][:name]
  action [:enable, :start]
  subscribes :restart, "template[#{node[:openstack][:config].gsub(/\\/, "/")}/nova.conf]"
end
