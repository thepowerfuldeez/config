#!/usr/bin/env swift
// The shell-role association used by macOS terminal applications.
import Foundation
import CoreServices

let type = "public.unix-executable" as CFString
let role = LSRolesMask(rawValue: 0x00000008) // kLSRolesShell
let ghostty = "com.mitchellh.ghostty" as CFString
let status = LSSetDefaultRoleHandlerForContentType(type, role, ghostty)
guard status == noErr else {
    fputs("Could not set Ghostty as the default terminal: \(status)\n", stderr)
    exit(1)
}
let current = LSCopyDefaultRoleHandlerForContentType(type, role)?.takeRetainedValue()
guard (current as String?) == (ghostty as String) else {
    fputs("Default terminal verification failed\n", stderr)
    exit(1)
}
print("Default terminal: Ghostty")
