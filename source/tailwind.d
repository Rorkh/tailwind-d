import std.process : Pid, spawnProcess, kill;
import std.exception : basicExceptionCtors;
import std.file : exists;
import std.stdio : File;
import std.array : split;

/**
    * Tailwind related exception
*/
class TailwindException : Exception
{
    mixin basicExceptionCtors;
}

class Tailwind
{
    private:
        /**
            * Default location to tailwind config
            *
            * If noConfig isn't true it will be passed to cli and config file with this path will be generated
        */
        const defaultConfigLocation = "assets/tailwind.config.js";

        /**
            * Pid of tailwind cli
        */
        Pid pid;
    
    public:
        /**
            * Input css file location
        */
        string input;

        /**
            * Output css file location
        */
        string output;

        /**
            * Tailwind config file location
        */
        string config;

        /**
            * Command to run tailwind cli
        */
        string command = "npx tailwindcss";

        /**
            * If tailwind config should not be generated and passed in params to cli or not
            *
            * Warning! This doesn't guarantee that tailwind cli will not find config location by itself
        */
        bool noConfig = false;

        /**
            * Writes tailwind config file to specified path (if it's not empty) or default location
        */
        void install_configuration(string configPath)
        {
            auto config = File(configPath, "w");
            config.write(import("tailwind.config.js"));
            config.close();
        }

        /**
            * Installs config if required (noConfig == false) and starts tailwind watch
        */
        void run()
        {
            if (!input) { throw new TailwindException("No CSS input specified."); }
            if (!output) { throw new TailwindException("No CSS output specified."); }

            if (!config && noConfig == false) { config = defaultConfigLocation; }
            if (config && !config.exists && noConfig == false) { install_configuration(config); }

            string[] args = command.split ~ ["-i", input, "-o", output];
            if (noConfig == false) { args ~= ["-c", config != "" ? config : defaultConfigLocation]; }

            pid = spawnProcess(args ~ "-w");
        }
    
    /**
        * Tailwind class destructors
        *
        * Destroys tailwind cli process
    */
    ~this()
    {
        kill(pid, 1);
    }
}