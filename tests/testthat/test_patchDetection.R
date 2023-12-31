test_that("patchDetection function works", {
    library(cytomapper)
    data(pancreasSCE)
    
    cur_sce1 <- pancreasSCE[,pancreasSCE$ImageNb == 1]
    cur_sce2 <- pancreasSCE[,pancreasSCE$ImageNb == 2]
    cur_sce3 <- pancreasSCE[,pancreasSCE$ImageNb == 3]
    
    cur_sce1$Pos_X <- cur_sce1$Pos_X - min(cur_sce1$Pos_X)
    cur_sce1$Pos_Y <- cur_sce1$Pos_Y - min(cur_sce1$Pos_Y)
    cur_sce2$Pos_X <- cur_sce2$Pos_X - min(cur_sce2$Pos_X)
    cur_sce2$Pos_Y <- cur_sce2$Pos_Y - min(cur_sce2$Pos_Y)
    cur_sce3$Pos_X <- cur_sce3$Pos_X - min(cur_sce3$Pos_X)
    cur_sce3$Pos_Y <- cur_sce3$Pos_Y - min(cur_sce3$Pos_Y)
    
    pancreasSCE <- cbind(cur_sce1, cur_sce2, cur_sce3)
    
    pancreasSCE <- buildSpatialGraph(pancreasSCE, img_id = "ImageNb", 
                                    type = "expansion", threshold = 20)

    expect_silent(cur_sce <- patchDetection(pancreasSCE, 
                                   patch_cells = pancreasSCE$CellType == "celltype_B",
                                   colPairName = "expansion_interaction_graph"))
    
    expect_true(is(cur_sce, "SingleCellExperiment"))
    expect_true("patch_id" %in% names(colData(cur_sce)))
    expect_equal(unique(cur_sce$patch_id), c(NA, "1", "2", "3", "4", "5", "6", "7", "8"))
    
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "CellType")  
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    expect_silent(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "expansion_interaction_graph",
                                            min_patch_size = 5))
    
    expect_equal(unique(cur_sce$patch_id), c(NA, "6", "7", "8"))
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    expect_silent(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType %in% c("celltype_B", "celltype_A"),
                                            colPairName = "expansion_interaction_graph"))
    expect_equal(unique(cur_sce$patch_id), c(NA, "1", "2", "3"))
    
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    expect_silent(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType %in% c("celltype_B", "celltype_A", "celltype_C"),
                                            colPairName = "expansion_interaction_graph"))
    expect_equal(unique(cur_sce$patch_id), c("1", "2", "3"))
    
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    expect_message(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "expansion_interaction_graph",
                                            expand_by = 10, img_id = "ImageNb",
                                            name = "patch_id_2"), 
                  regex = "The returned object is ordered by the 'ImageNb' entry.")
    expect_equal(unique(cur_sce$patch_id_2), c(NA, "1", "2", "3", "4", "5", "6", "7", "8"))
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id_2")
    
    expect_message(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "expansion_interaction_graph",
                                            expand_by = 50, img_id = "ImageNb",
                                            name = "patch_id"), 
                  regex = "The returned object is ordered by the 'ImageNb' entry.")
    expect_equal(unique(cur_sce$patch_id), c(NA,  "1", "3", "6", "7", "8"))
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    expect_message(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "expansion_interaction_graph",
                                            expand_by = 1000, img_id = "ImageNb",
                                            name = "patch_id"), 
                  regex = "The returned object is ordered by the 'ImageNb' entry.")
    expect_equal(unique(cur_sce$patch_id), c("3", "6", "7", "8"))
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    expect_message(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "expansion_interaction_graph",
                                            expand_by = 20, img_id = "ImageNb",
                                            name = "patch_id",
                                            min_patch_size = 5), 
                   regex = "The returned object is ordered by the 'ImageNb' entry.")
    expect_equal(unique(cur_sce$patch_id), c(NA, "6", "7", "8"))
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    cur_sce_2 <- pancreasSCE
    cur_sce_2$X <- cur_sce_2$Pos_X
    cur_sce_2$Y <- cur_sce_2$Pos_Y    
    cur_sce_2$Pos_X <- NULL
    cur_sce_2$Pos_y <- NULL
    
    expect_message(cur_sce <- patchDetection(cur_sce_2, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "expansion_interaction_graph",
                                            expand_by = 30,
                                            img_id = "ImageNb",
                                            coords = c("X", "Y")), 
                  regex = "The returned object is ordered by the 'ImageNb' entry.")
    
    expect_equal(unique(cur_sce$patch_id), c(NA, "1", "3", "4", "6", "7", "8"))
    
    # Concave and convex
    expect_message(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "expansion_interaction_graph",
                                            expand_by = 1, img_id = "ImageNb",
                                            name = "patch_id",
                                            convex = TRUE), 
                  regex = "The returned object is ordered by the 'ImageNb' entry.")
    expect_equal(unique(cur_sce$patch_id), c(NA, "1", "2", "3", "4", "5", "6", "7", "8"))
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    expect_message(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "expansion_interaction_graph",
                                            expand_by = 20, img_id = "ImageNb",
                                            name = "patch_id",
                                            convex = TRUE), 
                  regex = "The returned object is ordered by the 'ImageNb' entry.")
    expect_equal(unique(cur_sce$patch_id), c(NA, "1", "2", "3", "4", "5", "6", "7", "8"))
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    expect_message(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "expansion_interaction_graph",
                                            expand_by = 1000, img_id = "ImageNb",
                                            name = "patch_id",
                                            convex = TRUE), 
                  regex = "The returned object is ordered by the 'ImageNb' entry.")
    expect_equal(unique(cur_sce$patch_id), c("3", "6", "7", "8"))
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    # Other graph constructors
    pancreasSCE <- buildSpatialGraph(pancreasSCE, img_id = "ImageNb", 
                                     type = "expansion", threshold = 1)
    
    expect_error(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "expansion_interaction_graph"),
                 regexp = "No interactions found.",
                 fixed = TRUE)
    
    pancreasSCE <- buildSpatialGraph(pancreasSCE, img_id = "ImageNb", 
                                     type = "expansion", threshold = 10)
    expect_silent(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "expansion_interaction_graph"))
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    expect_equal(unique(cur_sce$patch_id), c(NA, as.character(seq_len(39))))
    
    pancreasSCE <- buildSpatialGraph(pancreasSCE, img_id = "ImageNb", 
                                     type = "knn", k = 3)
    expect_silent(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "knn_interaction_graph"))
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    expect_equal(unique(cur_sce$patch_id), c(NA, as.character(seq_len(13))))
    
    pancreasSCE <- buildSpatialGraph(pancreasSCE, img_id = "ImageNb", 
                                     type = "delaunay")
    expect_silent(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "delaunay_interaction_graph"))
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    expect_equal(unique(cur_sce$patch_id), c(NA, as.character(seq_len(9))))
    
    # Spatial Experiment
    cur_spe <- SpatialExperiment:::.sce_to_spe(pancreasSCE, sample_id = as.character(pancreasSCE$ImageNb))
    spatialCoords(cur_spe) <- as.matrix(colData(pancreasSCE)[,c("Pos_X", "Pos_Y")])
    colData(cur_spe)[c("Pos_X", "Pos_Y")] <- NULL
    
    cur_spe <- buildSpatialGraph(cur_spe, img_id = "ImageNb", 
                                     type = "expansion", threshold = 20)
    
    expect_message(cur_spe_2 <- patchDetection(cur_spe, 
                                            patch_cells = cur_spe$CellType == "celltype_B",
                                            colPairName = "expansion_interaction_graph",
                                            expand_by = 10, img_id = "ImageNb",
                                            name = "patch_id_2"), 
                  regex = "The returned object is ordered by the 'ImageNb' entry.")
    expect_equal(unique(cur_spe_2$patch_id_2), c(NA, "1", "2", "3", "4", "5", "6", "7", "8"))
    plotSpatial(cur_spe_2, img_id = "ImageNb", node_color_by = "patch_id_2")
    
    cur_spe_3 <- buildSpatialGraph(pancreasSCE, img_id = "ImageNb", 
                                 type = "expansion", threshold = 20)
    
    expect_message(cur_spe_3 <- patchDetection(cur_spe_3, 
                                              patch_cells = cur_spe_3$CellType == "celltype_B",
                                              colPairName = "expansion_interaction_graph",
                                              expand_by = 10, img_id = "ImageNb",
                                              name = "patch_id_2"), 
                  regex = "The returned object is ordered by the 'ImageNb' entry.")
    expect_equal(cur_spe_3$patch_id_2, cur_spe_2$patch_id_2)
    plotSpatial(cur_spe_3, img_id = "ImageNb", node_color_by = "patch_id_2")
    
    # Check that metadata is not duplicated
    cur_sce <- pancreasSCE
    metadata(cur_sce) <- list(test = c(1,2))
    
    cur_sce <- patchDetection(cur_sce, 
                              patch_cells = cur_sce$CellType == "celltype_B",
                              colPairName = "expansion_interaction_graph")
    
    expect_equal(length(metadata(cur_sce)), 1)
    expect_equal(metadata(cur_sce), list(test = c(1, 2)))
    
    int_metadata(cur_sce) <- list(version = "1.16.0")
    
    cur_sce <- buildSpatialGraph(cur_sce, img_id = "ImageNb", 
                                 type = "knn", k = 5)
    
    expect_equal(length(int_metadata(cur_sce)), 1)
    expect_equal(int_metadata(cur_sce), list(version = "1.16.0"))
    
    # Check for sparse graphs
    cur_sce <- pancreasSCE
    cur_sce <- buildSpatialGraph(cur_sce, img_id = "ImageNb", 
                                     type = "expansion", threshold = 10)
    
    expect_silent(cur_sce <- patchDetection(cur_sce, 
                                            patch_cells = cur_sce$CellType == "celltype_C",
                                            colPairName = "expansion_interaction_graph"))
    
    # Error
    expect_error(patchDetection("test"),
                 regexp = "'object' not of type 'SingleCellExperiment'.",
                 fixed = TRUE)
    expect_error(patchDetection(pancreasSCE, patch_cells = "test"),
                 regexp = "'patch_cells' must all be logical.",
                 fixed = TRUE)
    expect_error(patchDetection(pancreasSCE, patch_cells = TRUE),
                 regexp = "Length of 'patch_cells' must match the number of cells in 'object'.",
                 fixed = TRUE)
    expect_error(patchDetection(pancreasSCE, patch_cells = pancreasSCE$Pattern,
                                colPairName = 1),
                 regexp = "'colPairName' must be a single string.",
                 fixed = TRUE)
    expect_error(patchDetection(pancreasSCE, patch_cells = pancreasSCE$Pattern,
                                colPairName = "test"),
                 regexp = "'colPairName' not in 'colPairNames(object)'.",
                 fixed = TRUE)
    expect_error(patchDetection(pancreasSCE, patch_cells = pancreasSCE$Pattern,
                                colPairName = "expansion_interaction_graph",
                                min_patch_size = c(1,2)),
                 regexp = "'min_patch_size' must be a single numeric.",
                 fixed = TRUE)
    expect_error(patchDetection(pancreasSCE, patch_cells = pancreasSCE$Pattern,
                                colPairName = "expansion_interaction_graph",
                                coords = 1),
                 regexp = "'coords' must be a character vector of length 2.",
                 fixed = TRUE)
    expect_error(patchDetection(pancreasSCE, patch_cells = pancreasSCE$Pattern,
                                colPairName = "expansion_interaction_graph",
                                coords = c("test", "Pos_y")),
                 regexp = "'coords' not in colData(object).",
                 fixed = TRUE)
    expect_error(patchDetection(cur_spe, patch_cells = pancreasSCE$Pattern,
                                colPairName = "expansion_interaction_graph",
                                coords = c("test", "Pos_y")),
                 regexp = "'coords' not in spatialCoords(object).",
                 fixed = TRUE)
    expect_error(patchDetection(pancreasSCE, patch_cells = pancreasSCE$Pattern,
                                colPairName = "expansion_interaction_graph",
                                name = c("test", "Pos_y")),
                 regexp = "'name' must be a single string.",
                 fixed = TRUE)
    expect_error(patchDetection(pancreasSCE, patch_cells = pancreasSCE$Pattern,
                                colPairName = "expansion_interaction_graph",
                                expand_by = "test"),
                 regexp = "'expand_by' must be a single numeric.",
                 fixed = TRUE)
    expect_error(patchDetection(pancreasSCE, patch_cells = pancreasSCE$Pattern,
                                colPairName = "expansion_interaction_graph",
                                convex = "test"),
                 regexp = "'convex' must be a single logical.",
                 fixed = TRUE)
    expect_error(patchDetection(pancreasSCE, patch_cells = pancreasSCE$Pattern,
                                colPairName = "expansion_interaction_graph",
                                expand_by = 10),
                 regexp = "'img_id' must be specified when patch expansion is performed.",
                 fixed = TRUE)
    expect_error(patchDetection(pancreasSCE, patch_cells = pancreasSCE$Pattern,
                                colPairName = "expansion_interaction_graph",
                                expand_by = 10, img_id = 1),
                 regexp = "'img_id' must be a single string.",
                 fixed = TRUE)
    expect_error(patchDetection(pancreasSCE, patch_cells = pancreasSCE$Pattern,
                                colPairName = "expansion_interaction_graph",
                                expand_by = 10, img_id = "test"),
                 regexp = "'img_id' not in colData(object).",
                 fixed = TRUE)
                     
})

test_that("patchDetection function works if cells are not ordered by image", {
    library(cytomapper)
    data(pancreasSCE)
    
    cur_sce1 <- pancreasSCE[,pancreasSCE$ImageNb == 1]
    cur_sce2 <- pancreasSCE[,pancreasSCE$ImageNb == 2]
    cur_sce3 <- pancreasSCE[,pancreasSCE$ImageNb == 3]
    
    cur_sce1$Pos_X <- cur_sce1$Pos_X - min(cur_sce1$Pos_X)
    cur_sce1$Pos_Y <- cur_sce1$Pos_Y - min(cur_sce1$Pos_Y)
    cur_sce2$Pos_X <- cur_sce2$Pos_X - min(cur_sce2$Pos_X)
    cur_sce2$Pos_Y <- cur_sce2$Pos_Y - min(cur_sce2$Pos_Y)
    cur_sce3$Pos_X <- cur_sce3$Pos_X - min(cur_sce3$Pos_X)
    cur_sce3$Pos_Y <- cur_sce3$Pos_Y - min(cur_sce3$Pos_Y)
    
    pancreasSCE <- cbind(cur_sce1, cur_sce2, cur_sce3)
    
    pancreasSCE <- buildSpatialGraph(pancreasSCE, img_id = "ImageNb", 
                                     type = "expansion", threshold = 20)
    pancreasSCE$index <- 1:ncol(pancreasSCE)
    
    expect_silent(cur_sce <- patchDetection(pancreasSCE, 
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            colPairName = "expansion_interaction_graph"))
    
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "CellType")  
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    set.seed(1234)
    shuffled_sce <- pancreasSCE[,sample(ncol(pancreasSCE))]
    
    cur_sce2 <- patchDetection(shuffled_sce, 
                               patch_cells = shuffled_sce$CellType == "celltype_B",
                               colPairName = "expansion_interaction_graph")
    
    plotSpatial(cur_sce2, img_id = "ImageNb", node_color_by = "CellType")  
    plotSpatial(cur_sce2, img_id = "ImageNb", node_color_by = "patch_id")
    
    expect_equal(is.na(cur_sce2$patch_id[order(cur_sce2$index)]), is.na(cur_sce$patch_id[order(cur_sce$index)]))
    
    expect_message(cur_sce <- patchDetection(pancreasSCE, img_id = "ImageNb",
                                            patch_cells = pancreasSCE$CellType == "celltype_B",
                                            expand_by = 10,
                                            colPairName = "expansion_interaction_graph"), 
                  regex = "The returned object is ordered by the 'ImageNb' entry.")
    
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "CellType")  
    plotSpatial(cur_sce, img_id = "ImageNb", node_color_by = "patch_id")
    
    set.seed(1234)
    shuffled_sce <- pancreasSCE[,sample(ncol(pancreasSCE))]
    
    cur_sce2 <- patchDetection(shuffled_sce, img_id = "ImageNb",
                               expand_by = 10,
                               patch_cells = shuffled_sce$CellType == "celltype_B",
                               colPairName = "expansion_interaction_graph")
    
    plotSpatial(cur_sce2, img_id = "ImageNb", node_color_by = "CellType")  
    plotSpatial(cur_sce2, img_id = "ImageNb", node_color_by = "patch_id")
    
    expect_equal(is.na(cur_sce2$patch_id[order(cur_sce2$index)]), is.na(cur_sce$patch_id[order(cur_sce$index)]))
    
    })
