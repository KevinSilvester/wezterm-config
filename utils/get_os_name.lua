-- get_os_name(), funtion to return current OS name and architecture
-- Copyright Philippe Fremy 2017
--
-- This code is based on the following Gist from Soulik (https://gist.github.com/soulik)
-- https://gist.github.com/soulik/82e9d02a818ce12498d1
-- Initial license was unspecified so I am assuming public domain

local M = {}

function M.get_os_name()
   -- Return two strings describing the OS name and OS architecture.
   -- For Windows, the OS identification is based on environment variables
   -- On unix, a call to uname is used.
   --
   -- OS possible values: Windows, Linux, Mac, BSD, Solaris
   -- Arch possible values: x86, x86864, powerpc, arm, mips
   --
   -- On Windows, detection based on environment variable is limited
   -- to what Windows is willing to tell through environement variables. In particular
   -- 64bits is not always indicated so do not rely hardly on this value.

   local raw_os_name, raw_arch_name = "", ""

   -- LuaJIT shortcut
   if jit and jit.os and jit.arch then
      raw_os_name = jit.os
      raw_arch_name = jit.arch
      -- print( ("Debug jit name: %q %q"):format( raw_os_name, raw_arch_name ) )
   else
      if package.config:sub(1, 1) == "\\" then
         -- Windows
         local env_OS = os.getenv("OS")
         local env_ARCH = os.getenv("PROCESSOR_ARCHITECTURE")
         -- print( ("Debug: %q %q"):format( env_OS, env_ARCH ) )
         if env_OS and env_ARCH then
            raw_os_name, raw_arch_name = env_OS, env_ARCH
         end
      else
         -- other platform, assume uname support and popen support
         raw_os_name = io.popen("uname -s", "r"):read("*l")
         raw_arch_name = io.popen("uname -m", "r"):read("*l")
      end
   end

   raw_os_name = (raw_os_name):lower()
   raw_arch_name = (raw_arch_name):lower()

   -- print( ("Debug: %q %q"):format( raw_os_name, raw_arch_name) )

   local os_patterns = {
      ["windows"] = "Windows",
      ["linux"] = "Linux",
      ["osx"] = "Mac",
      ["mac"] = "Mac",
      ["darwin"] = "Mac",
      ["^mingw"] = "Windows",
      ["^cygwin"] = "Windows",
      ["bsd$"] = "BSD",
      ["sunos"] = "Solaris",
   }

   local arch_patterns = {
      ["^x86$"] = "x86",
      ["i[%d]86"] = "x86",
      ["amd64"] = "x86_64",
      ["x86_64"] = "x86_64",
      ["x64"] = "x86_64",
      ["power macintosh"] = "powerpc",
      ["^arm"] = "arm",
      ["^mips"] = "mips",
      ["i86pc"] = "x86",
   }

   local os_name, arch_name = "unknown", "unknown"

   for pattern, name in pairs(os_patterns) do
      if raw_os_name:match(pattern) then
         os_name = name
         break
      end
   end
   for pattern, name in pairs(arch_patterns) do
      if raw_arch_name:match(pattern) then
         arch_name = name
         break
      end
   end
   return os_name, arch_name
end

-- heuristic for detecting standalone script
if ... ~= "get_os_name" then
   -- main
   print(("%q %q"):format(M.get_os_name()))
end

return M
