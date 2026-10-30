---@type Config
return {
   ssh_domains = {},
   unix_domains = {},

   wsl_domains = {
      {
         name = 'Ubuntu',
         distribution = 'Ubuntu',
         username = 'boshh',
         default_cwd = '/home/boshh',
         default_prog = { 'bash', '-l' },
      },
   },
}
