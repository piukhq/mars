#!/bin/bash
function zip_project() {
    # Create zip
    zip -r mobsf_files.zip binkapp
    zip -ur mobsf_files.zip binkapp.xcodeproj 
    zip -ur mobsf_files.zip binkapp.xcworkspace
    envman add --key "MOBSF_STATIC_FILE"  --value "mobsf_files.zip"
}

zip_project