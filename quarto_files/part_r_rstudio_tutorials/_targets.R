library(targets)
library(future.apply)
plan(multisession)
compute_with_checkpoint <- function(x, checkpoint_dir) {
    checkpoint_file <- file.path(checkpoint_dir, paste0("result_", 
        x, ".rds"))
    if (file.exists(checkpoint_file)) {
        result <- readRDS(checkpoint_file)
    }
    else {
        Sys.sleep(2)
        result <- x^2
        saveRDS(result, checkpoint_file)
    }
    return(result)
}
tar_option_set(packages = c("future.apply"), format = "rds")
list(tar_target(checkpoint_dir, {
    dir <- "/home/vetinst.no/vi2313/R-tutorials/data/part_r_rstudio_tutorials/parallelization_on_workbench/checkpoints_targets/"
    dir.create(dir, showWarnings = FALSE)
    dir
}, format = "file"), tar_target(data, seq(1, 10), format = "rds"), 
    tar_target(results, future_lapply(data, compute_with_checkpoint, 
        checkpoint_dir = checkpoint_dir), format = "rds"), tar_target(final_save, 
        {
            saveRDS(results, "/home/vetinst.no/vi2313/R-tutorials/data/part_r_rstudio_tutorials/parallelization_on_workbench/checkpoints_targets/final_results.rds")
            results
        }, format = "rds"))
