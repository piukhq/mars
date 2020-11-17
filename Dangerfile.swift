import Danger

let danger = Danger()
let mergeRequest = danger.gitLab.mergeRequest

let reviewer = mergeRequest.assignee
if reviewer == nil {
    warn("Merge request is not assigned. Please assign a reviewer.")
}

let labels = mergeRequest.labels
if labels.isEmpty {
    warn("Merge request has no labels. Please add labels to indicate the status of the MR.")
}

let modifiedFiles = danger.git.modifiedFiles
let editedFiles = modifiedFiles + danger.git.createdFiles
let testFiles = editedFiles.filter { ($0.contains("Tests")) || ($0.contains("Test")) && ($0.fileType == .swift) }
if testFiles.isEmpty {
    warn("Tests were not updated.")
}

if editedFiles.contains("Podfile.swift") {
    warn("Merge request contains changes to the Podfile.")
}

let bigMRThreshold = 500
let changes = danger.git.createdFiles + danger.git.deletedFiles + danger.git.modifiedFiles
if changes.count > bigMRThreshold {
    warn("Merge request is large. Consider breaking up into multiple merge requests.")
}

if mergeRequest.description.isEmpty {
    warn("Merge request description is empty. Please add a description, and consider using a template to give the reviewer more context.")
}

if mergeRequest.title.count < 15 {
    warn("Merge request title is too short. The title should containt at least the JIRA ticket number and a short summary of the changes. For example, 'IB20-1234: Fix bug where app was crashing on launch'")
}

if !mergeRequest.title.contains("IB20") {
    warn("Merge request title should include a JIRA ticket number.")
}

if !mergeRequest.description.contains("IB20") {
    warn("Merge request description should include a JIRA ticket number.")
}

xcov.report(
  scheme: 'binkapp beta',
  workspace: 'binkapp.xcworkspace',
  xccov_file_direct_path: ENV['BITRISE_XCRESULT_PATH']
)
