test_that("Test that list_available_cancer_types works", {
  dir <- "/projects/marralab/ytakemon_prj/DepMap/GINIR_data/data"
  
  # To list all types
  res1 <- list_available_cancer_types(data_dir = dir)
  expect_equal(length(res1), 37)
  
  # To list all subtypes
  res2 <- list_available_cancer_subtypes("Lung Cancer", data_dir = dir)
  expect_equal(length(res2), 11)
})
