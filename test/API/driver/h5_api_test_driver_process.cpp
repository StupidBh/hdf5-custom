/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Copyright by The HDF Group.                                               *
 * All rights reserved.                                                      *
 *                                                                           *
 * This file is part of HDF5.  The full HDF5 copyright notice, including     *
 * terms governing use, modification, and redistribution, is contained in    *
 * the LICENSE file, which can be found at the root of the source code       *
 * distribution tree, or in https://www.hdfgroup.org/licenses.               *
 * If you do not have access to either file, you may request a copy from     *
 * help@hdfgroup.org.                                                        *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string>
#include <thread>

#ifdef _WIN32
    #include <windows.h>
#else
    #include <cerrno>
    #include <csignal>
    #include <sys/types.h>
    #include <unistd.h>
#endif

namespace {

    using process_id_t = unsigned long long;

    process_id_t current_process_id()
    {
#ifdef _WIN32
        return static_cast<process_id_t>(GetCurrentProcessId());
#else
        return static_cast<process_id_t>(getpid());
#endif
    }

    bool process_is_running(process_id_t process_id)
    {
#ifdef _WIN32
        HANDLE process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, static_cast<DWORD>(process_id));
        if (!process) {
            return GetLastError() != ERROR_INVALID_PARAMETER;
        }

        DWORD exit_code = 0;
        bool running = GetExitCodeProcess(process, &exit_code) && exit_code == STILL_ACTIVE;
        CloseHandle(process);
        return running;
#else
        int result = kill(static_cast<pid_t>(process_id), 0);
        return result == 0 || errno == EPERM;
#endif
    }

    void terminate_process(process_id_t process_id)
    {
#ifdef _WIN32
        HANDLE process = OpenProcess(PROCESS_TERMINATE | SYNCHRONIZE, FALSE, static_cast<DWORD>(process_id));
        if (process) {
            TerminateProcess(process, 1);
            WaitForSingleObject(process, 5000);
            CloseHandle(process);
        }
#else
        kill(static_cast<pid_t>(process_id), SIGTERM);
        for (int attempt = 0; attempt < 20 && process_is_running(process_id); attempt++) {
            std::this_thread::sleep_for(std::chrono::milliseconds(50));
        }
        if (process_is_running(process_id)) {
            kill(static_cast<pid_t>(process_id), SIGKILL);
        }
#endif
    }

    int verify_terminated(const char* pid_file_name)
    {
        std::ifstream pid_file(pid_file_name);
        process_id_t process_id = 0;

        if (!(pid_file >> process_id)) {
            std::cerr << "Unable to read the controlled process ID from " << pid_file_name << '\n';
            return 2;
        }

        if (!process_is_running(process_id)) {
            return 0;
        }

        terminate_process(process_id);
        std::cerr << "Controlled process " << process_id << " remained alive after the driver exited\n";
        return 3;
    }

} // namespace

int main(int argc, char* argv[])
{
    if (argc == 1 || ((argc == 2 || argc == 3) && std::string(argv[1]) == "server")) {
        if (argc == 3) {
            std::ofstream pid_file(argv[2], std::ios::trunc);
            if (!pid_file) {
                std::cerr << "Unable to write the controlled process ID to " << argv[2] << '\n';
                return 2;
            }
            pid_file << current_process_id() << '\n';
        }

        std::cout << "Waiting\n";
        std::cout.flush();
        std::this_thread::sleep_for(std::chrono::seconds(30));
        return 0;
    }

    if (argc == 3 && std::string(argv[1]) == "exit") {
        std::cout << "Controlled client started\n";
        std::cout.flush();
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        return std::atoi(argv[2]);
    }

    if (argc == 4 && std::string(argv[1]) == "sleep") {
        std::ofstream pid_file(argv[3], std::ios::trunc);
        if (!pid_file) {
            std::cerr << "Unable to write the controlled process ID to " << argv[3] << '\n';
            return 2;
        }
        pid_file << current_process_id() << '\n';
        pid_file.close();

        std::cout << "Controlled client sleeping\n";
        std::cout.flush();
        std::this_thread::sleep_for(std::chrono::milliseconds(std::atoi(argv[2])));
        return 0;
    }

    if (argc == 3 && std::string(argv[1]) == "verify-terminated") {
        return verify_terminated(argv[2]);
    }

    std::cerr << "Usage: " << argv[0] << " [server [pid-file]] | exit <code> | sleep <milliseconds> <pid-file> | verify-terminated <pid-file>\n";
    return 2;
}
