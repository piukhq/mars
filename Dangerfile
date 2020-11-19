# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example

##warn "Merge request is not assigned. Please assign a reviewer." unless gitlab.mr_json["assignee"]

##failure "Merge request has no labels. Please add labels to indicate the status of the MR." if gitlab.mr_labels.empty?

# Generate report
report = xcov.produce_report(
  scheme: 'binkapp beta',
  workspace: 'binkapp.xcworkspace',
  only_project_targets: true,
  xccov_file_direct_path: ENV['BITRISE_XCRESULT_PATH']
)

# Post markdown report
xcov.output_report(report)