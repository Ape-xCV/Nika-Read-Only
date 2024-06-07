#pragma once
namespace mem {
    pid_t m_pid = 0;

    pid_t GetPID() {
        if (m_pid > 0) return m_pid;
        char buf[512];
        FILE* cmd_pipe = popen("pidof -s r5apex.exe", "r");
        fgets(buf, 512, cmd_pipe);
        pid_t pid = strtoul(buf, NULL, 10);
        pclose(cmd_pipe);
        m_pid = pid;
        return pid;
    }
    bool IsValidPointer(long Pointer) {
        return Pointer > 0x00010000 && Pointer < 0x7FFFFFFEFFFF;
    }
    bool Read(long address, void* pBuff, size_t size) {
        if (size == 0)
            return false;
        void* pAddress = (void*)address;
        pid_t pid = GetPID();
        struct iovec iovLocalAddressSpace[1]{ 0 };
        struct iovec iovRemoteAddressSpace[1]{ 0 };
        iovLocalAddressSpace[0].iov_base = pBuff;     // Store data in this buffer
        iovLocalAddressSpace[0].iov_len = size;       // which has this size.
        iovRemoteAddressSpace[0].iov_base = pAddress; // The data comes from here
        iovRemoteAddressSpace[0].iov_len = size;      // and has this size.
        ssize_t sSize = process_vm_readv(
            pid,                   // Remote process id
            iovLocalAddressSpace,  // Local iovec array
            1,                     // Size of the local iovec array
            iovRemoteAddressSpace, // Remote iovec array
            1,                     // Size of the remote iovec array
            0);                    // Flags, unused
        if (sSize == (ssize_t)size)
            return true;
        else if (sSize == 0)
            return false;
        return false;
    }
    bool Write(long address, void* pBuff, size_t size) {
        if (size == 0)
            return false;
        void* pAddress = (void*)address;
        pid_t pid = GetPID();
        struct iovec iovLocalAddressSpace[1]{ 0 };
        struct iovec iovRemoteAddressSpace[1]{ 0 };
        iovLocalAddressSpace[0].iov_base = pBuff;     // Store data in this buffer
        iovLocalAddressSpace[0].iov_len = size;       // which has this size.
        iovRemoteAddressSpace[0].iov_base = pAddress; // The data will be writted here
        iovRemoteAddressSpace[0].iov_len = size;      // and has this size.
        ssize_t sSize = process_vm_writev(
            pid,                   // Remote process id
            iovLocalAddressSpace,  // Local iovec array
            1,                     // Size of the local iovec array
            iovRemoteAddressSpace, // Remote iovec array
            1,                     // Size of the remote iovec array
            0);                    // Flags, unused
        if (sSize == (ssize_t)size)
            return true;
        else if (sSize == 0)
            return false;
        return false;
    }
    std::string convertPointerToHexString(long pointer) {
        std::stringstream stream;
        stream << "0x" << std::hex << pointer;
        std::string result(stream.str());
        return result;
    }
    template <class T>
    void Write(long address, T value) {
        bool success = Write(address, &value, sizeof(T));
        if (!success) {
            m_pid = 0;
            throw std::invalid_argument(
                "Failed to write memory " + std::to_string(sizeof(T)) + " at: " + convertPointerToHexString(address));
        }
    }
    template <class T>
    T Read(long address, std::string stringRead) {
        T buffer;
        bool success = Read(address, &buffer, sizeof(T));
        if (!success) {
            m_pid = 0;
            throw std::invalid_argument("Failed to read memory [" + stringRead + "] at address : " + convertPointerToHexString(address));
        }
        return buffer;
    }
    void readbytearray(long address, char* buffer, int size) {
    	for (int i = 0; i < size; i++) {
    	    bool success = Read((long)(address + (long)i), &(buffer[i]), sizeof(char));
            if (!success)
                throw new std::invalid_argument("Failed to read byte at address: " + address);
    	}
    }
    std::string ReadString(long address, int size, std::string whatAreYouReading) {
        char buffer[size] = { 0 };
        bool success = Read(address, &buffer, size);
        if (!success) {
            m_pid = 0;
            throw std::invalid_argument("Failed to read memory string [" + whatAreYouReading + "] at address : " + convertPointerToHexString(address));
        }
        return std::string(buffer);
    }
}
