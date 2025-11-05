# Coveralls configuration
# Ensure JSON output is generated
%{
  default_stop_words: [],
  custom_stop_words: [],
  coverage_options: %{
    treat_no_relevant_lines_as_covered: true,
    output_dir: "cover/",
    minimum_coverage: 80
  }
}
