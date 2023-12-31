test_that("read_steinbock function works", {
    path <- system.file("extdata/mockData/steinbock", package = "imcRtools")
  
    # SpatialExperiment
    cur_spe <- read_steinbock(path)
    
    expect_equal(colnames(cur_spe), paste0(cur_spe$sample_id, "_", cur_spe$ObjectNumber))
    
    expect_s4_class(cur_spe, "SpatialExperiment")
    
    expect_equal(rownames(cur_spe), c("Ag107", "Cytokeratin 5", "Laminin", 
                                      "YBX1", "H3K27Ac"))
    expect_equal(assayNames(cur_spe), "counts")
    expect_equal(dim(cur_spe), c(5, 404))
    expect_equal(names(rowData(cur_spe)), 
                 c("channel", "name", "keep", "ilastik", "deepcell", "cellpose", 
                   "Tube.Number"))
    expect_equal(names(colData(cur_spe)), c("sample_id", "ObjectNumber", "area", 
                                            "axis_major_length", 
                                            "axis_minor_length", "eccentricity",
                                            "width_px", "height_px"))
    expect_equal(spatialCoordsNames(cur_spe), c("Pos_X", "Pos_Y"))
    
    cur_files <- list.files(file.path(path, "intensities"), full.names = TRUE)
    cur_counts <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_counts <- do.call("rbind", cur_counts)
    
    test1 <- counts(cur_spe)
    colnames(test1) <- NULL
    
    expect_equal(test1, t(cur_counts[,-1]))
    expect_equal(counts(cur_spe)[1:10], c(0.0909090909090909, 0.181818181818182, 0.0909090909090909, 
                                          0.0909090909090909, 0.938306353308938, 0.181163804871695, 0, 
                                          0.142857142857143, 0.501448290688651, 1.00346943310329))
    
    cur_files <- list.files(file.path(path, "regionprops"), full.names = TRUE)
    cur_morph <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_morph <- do.call("rbind", cur_morph)
    
    expect_equal(cur_spe$area, cur_morph$area)
    expect_equal(cur_spe$axis_major_length, cur_morph$axis_major_length)
    expect_equal(cur_spe$axis_minor_length, cur_morph$axis_minor_length)
    expect_equal(cur_spe$eccentricity, cur_morph$eccentricity)
    expect_equal(as.numeric(spatialCoords(cur_spe)[,1]), cur_morph$`centroid-1`)
    expect_equal(as.numeric(spatialCoords(cur_spe)[,2]), cur_morph$`centroid-0`)
    
    cur_panel <- readr::read_csv(file.path(path, "panel.csv"), show_col_types = FALSE)
    expect_equal(rowData(cur_spe)$name, cur_panel$name)
    expect_equal(rowData(cur_spe)$channel, cur_panel$channel)
    expect_equal(rowData(cur_spe)$keep, cur_panel$keep)
    expect_equal(rowData(cur_spe)$deepcell, cur_panel$deepcell)
    expect_equal(rowData(cur_spe)$ilastik, cur_panel$ilastik)
    expect_equal(rowData(cur_spe)$Tube.Number, cur_panel$`Tube Number`)
    
    cur_images <- readr::read_csv(file.path(path, "images.csv"), show_col_types = FALSE)
    cur_images <- cur_images[order(cur_images$image, decreasing = FALSE),]
    
    cur_test <- unique(colData(cur_spe)[,c("sample_id", "width_px", "height_px")])
    
    expect_equal(sub(".tiff$", "", cur_images$image), cur_test$sample_id)
    expect_equal(sub(".tiff$", "", cur_images$image), cur_test$sample_id)
    expect_equal(cur_images$width_px, cur_test$width_px)
    expect_equal(cur_images$height_px, cur_test$height_px)
    
    expect_equal(colPairNames(cur_spe), "neighborhood")
    
    expect_silent(cur_graphs <- colPair(cur_spe, "neighborhood"))
    
    for (i in unique(cur_spe$sample_id)) {
        cur_dat <- cur_spe[,cur_spe$sample_id == i]
        
        cur_test <- readr::read_csv(file.path(path, "neighbors", paste0(i, ".csv")), show_col_types = FALSE)
        
        expect_equal(cur_test$Object, from(colPair(cur_dat, "neighborhood")))
        expect_equal(cur_test$Neighbor, to(colPair(cur_dat, "neighborhood")))
    }
    
    # SingleCellExperiment
    cur_sce <- read_steinbock(path, return_as = "sce")
    
    expect_equal(colnames(cur_sce), paste0(cur_sce$sample_id, "_", cur_sce$ObjectNumber)) 
    
    expect_s4_class(cur_sce, "SingleCellExperiment")
    
    expect_equal(rownames(cur_sce), c("Ag107", "Cytokeratin 5", "Laminin", 
                                      "YBX1", "H3K27Ac"))
    expect_equal(assayNames(cur_sce), "counts")
    expect_equal(dim(cur_sce), c(5, 404))
    expect_equal(names(rowData(cur_sce)), 
                 c("channel", "name", "keep", "ilastik", "deepcell", "cellpose", "Tube.Number"))
    expect_equal(names(colData(cur_sce)), c("sample_id", "ObjectNumber", "Pos_X", 
                                            "Pos_Y", "area", 
                                            "axis_major_length", 
                                            "axis_minor_length", "eccentricity",
                                            "width_px", "height_px"))
    
    cur_files <- list.files(file.path(path, "intensities"), full.names = TRUE)
    cur_counts <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_counts <- do.call("rbind", cur_counts)
    
    test1 <- counts(cur_spe)
    colnames(test1) <- NULL
    
    expect_equal(test1, t(cur_counts[,-1]))
    expect_equal(counts(cur_sce)[1:10], c(0.0909090909090909, 0.181818181818182, 0.0909090909090909, 
                                         0.0909090909090909, 0.938306353308938, 0.181163804871695, 0, 
                                         0.142857142857143, 0.501448290688651, 1.00346943310329))
    
    cur_files <- list.files(file.path(path, "regionprops"), full.names = TRUE)
    cur_morph <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_morph <- do.call("rbind", cur_morph)
    
    expect_equal(cur_sce$area, cur_morph$area)
    expect_equal(cur_sce$axis_major_length, cur_morph$axis_major_length)
    expect_equal(cur_sce$axis_minor_length, cur_morph$axis_minor_length)
    expect_equal(cur_sce$eccentricity, cur_morph$eccentricity)
    expect_equal(as.numeric(cur_sce$Pos_X), cur_morph$`centroid-1`)
    expect_equal(as.numeric(cur_sce$Pos_Y), cur_morph$`centroid-0`)
    
    cur_panel <- readr::read_csv(file.path(path, "panel.csv"), show_col_types = FALSE)
    expect_equal(rowData(cur_sce)$name, cur_panel$name)
    expect_equal(rowData(cur_sce)$channel, cur_panel$channel)
    expect_equal(rowData(cur_sce)$keep, cur_panel$keep)
    expect_equal(rowData(cur_sce)$ilastik, cur_panel$ilastik)
    expect_equal(rowData(cur_sce)$deepcell, cur_panel$deepcell)    
    expect_equal(rowData(cur_sce)$Tube.Number, cur_panel$`Tube Number`)
    
    expect_equal(colPairNames(cur_sce), "neighborhood")
    
    expect_silent(cur_graphs <- colPair(cur_sce, "neighborhood"))
    
    for (i in unique(cur_sce$sample_id)) {
        cur_dat <- cur_sce[,cur_sce$sample_id == i]
        
        cur_test <- readr::read_csv(file.path(path, "neighbors", paste0(i, ".csv")), show_col_types = FALSE)
        
        expect_equal(cur_test$Object, from(colPair(cur_dat, "neighborhood")))
        expect_equal(cur_test$Neighbor, to(colPair(cur_dat, "neighborhood")))
    }
    
    cur_test <- unique(colData(cur_sce)[,c("sample_id", "width_px", "height_px")])
    
    expect_equal(sub(".tiff$", "", cur_images$image), cur_test$sample_id)
    expect_equal(sub(".tiff$", "", cur_images$image), cur_test$sample_id)
    expect_equal(cur_images$width_px, cur_test$width_px)
    expect_equal(cur_images$height_px, cur_test$height_px)
    
    # Test other import settings
    cur_spe <- read_steinbock(path, regionprops_folder = NULL)
    
    expect_equal(rownames(cur_spe), c("Ag107", "Cytokeratin 5", "Laminin", 
                                      "YBX1", "H3K27Ac"))
    expect_equal(assayNames(cur_spe), "counts")
    expect_equal(dim(cur_spe), c(5, 404))
    expect_equal(names(rowData(cur_spe)), 
                 c("channel", "name", "keep", "ilastik", "deepcell", "cellpose", "Tube.Number"))
    expect_equal(names(colData(cur_spe)), c("sample_id", "ObjectNumber", 
                                            "width_px", "height_px"))
    expect_null(spatialCoordsNames(cur_spe))
    
    cur_files <- list.files(file.path(path, "intensities"), full.names = TRUE)
    cur_counts <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_counts <- do.call("rbind", cur_counts)
    
    test1 <- counts(cur_spe)
    colnames(test1) <- NULL
    
    expect_equal(test1, t(cur_counts[,-1]))
    
    cur_files <- list.files(file.path(path, "regionprops"), full.names = TRUE)
    cur_morph <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_morph <- do.call("rbind", cur_morph)
    
    cur_panel <- readr::read_csv(file.path(path, "panel.csv"), show_col_types = FALSE)
    expect_equal(rowData(cur_spe)$name, cur_panel$name)
    expect_equal(rowData(cur_spe)$channel, cur_panel$channel)
    expect_equal(rowData(cur_spe)$keep, cur_panel$keep)
    expect_equal(rowData(cur_spe)$ilastik, cur_panel$ilastik)
    expect_equal(rowData(cur_spe)$deepcell, cur_panel$deepcell)
    expect_equal(rowData(cur_spe)$Tube.Number, cur_panel$`Tube Number`)
    
    expect_equal(colPairNames(cur_spe), "neighborhood")
    
    expect_silent(cur_graphs <- colPair(cur_spe, "neighborhood"))
    
    for (i in unique(cur_spe$sample_id)) {
        cur_dat <- cur_spe[,cur_spe$sample_id == i]
        
        cur_test <- readr::read_csv(file.path(path, "neighbors", paste0(i, ".csv")), show_col_types = FALSE)
        
        expect_equal(cur_test$Object, from(colPair(cur_dat, "neighborhood")))
        expect_equal(cur_test$Neighbor, to(colPair(cur_dat, "neighborhood")))
    }
    
    expect_equal(length(colPair(cur_spe)), 1674)
    
    cur_test <- unique(colData(cur_spe)[,c("sample_id", "width_px", "height_px")])
    
    expect_equal(sub(".tiff$", "", cur_images$image), cur_test$sample_id)
    expect_equal(sub(".tiff$", "", cur_images$image), cur_test$sample_id)
    expect_equal(cur_images$width_px, cur_test$width_px)
    expect_equal(cur_images$height_px, cur_test$height_px)
    
    cur_sce <- read_steinbock(path, return_as = "sce", regionprops_folder = NULL)
    
    expect_equal(rownames(cur_sce), c("Ag107", "Cytokeratin 5", "Laminin", 
                                      "YBX1", "H3K27Ac"))
    expect_equal(assayNames(cur_sce), "counts")
    expect_equal(dim(cur_sce), c(5, 404))
    expect_equal(names(rowData(cur_sce)), 
                 c("channel", "name", "keep", "ilastik", "deepcell", "cellpose", "Tube.Number"))
    expect_equal(names(colData(cur_sce)), c("sample_id", "ObjectNumber",
                                            "width_px", "height_px"))
    
    cur_files <- list.files(file.path(path, "intensities"), full.names = TRUE)
    cur_counts <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_counts <- do.call("rbind", cur_counts)
    
    test1 <- counts(cur_sce)
    colnames(test1) <- NULL
    
    expect_equal(test1, t(cur_counts[,-1]))
    
    cur_files <- list.files(file.path(path, "regionprops"), full.names = TRUE)
    cur_morph <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_morph <- do.call("rbind", cur_morph)
    
    cur_panel <- readr::read_csv(file.path(path, "panel.csv"), show_col_types = FALSE)
    expect_equal(rowData(cur_sce)$name, cur_panel$name)
    expect_equal(rowData(cur_sce)$channel, cur_panel$channel)
    expect_equal(rowData(cur_sce)$keep, cur_panel$keep)
    expect_equal(rowData(cur_sce)$ilastik, cur_panel$ilastik)
    expect_equal(rowData(cur_sce)$deepcell, cur_panel$deepcell)
    expect_equal(rowData(cur_sce)$Tube.Number, cur_panel$`Tube Number`)
    
    expect_equal(colPairNames(cur_sce), "neighborhood")
    
    expect_equal(length(colPair(cur_sce)), 1674)
    
    cur_spe <- read_steinbock(path, graphs_folder = NULL)
    
    expect_equal(rownames(cur_spe), c("Ag107", "Cytokeratin 5", "Laminin", 
                                      "YBX1", "H3K27Ac"))
    expect_equal(assayNames(cur_spe), "counts")
    expect_equal(dim(cur_spe), c(5, 404))
    expect_equal(names(rowData(cur_spe)), 
                 c("channel", "name", "keep", "ilastik", "deepcell", "cellpose", "Tube.Number"))
    expect_equal(names(colData(cur_spe)), c("sample_id", "ObjectNumber", "area", 
                                            "axis_major_length", 
                                            "axis_minor_length", "eccentricity",
                                            "width_px", "height_px"))
    expect_equal(spatialCoordsNames(cur_spe), c("Pos_X", "Pos_Y"))
    
    cur_files <- list.files(file.path(path, "intensities"), full.names = TRUE)
    cur_counts <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_counts <- do.call("rbind", cur_counts)
    
    test1 <- counts(cur_spe)
    colnames(test1) <- NULL
    
    expect_equal(test1, t(cur_counts[,-1]))
    
    cur_files <- list.files(file.path(path, "regionprops"), full.names = TRUE)
    cur_morph <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_morph <- do.call("rbind", cur_morph)
    
    expect_equal(cur_spe$area, cur_morph$area)
    expect_equal(cur_spe$axis_major_length, cur_morph$axis_major_length)
    expect_equal(cur_spe$axis_minor_length, cur_morph$axis_minor_length)
    expect_equal(cur_spe$eccentricity, cur_morph$eccentricity)
    expect_equal(as.numeric(spatialCoords(cur_spe)[,1]), cur_morph$`centroid-1`)
    expect_equal(as.numeric(spatialCoords(cur_spe)[,2]), cur_morph$`centroid-0`)
    
    cur_panel <- readr::read_csv(file.path(path, "panel.csv"), show_col_types = FALSE)
    expect_equal(rowData(cur_spe)$name, cur_panel$name)
    expect_equal(rowData(cur_spe)$channel, cur_panel$channel)
    expect_equal(rowData(cur_spe)$keep, cur_panel$keep)
    expect_equal(rowData(cur_spe)$deepcell, cur_panel$deepcell)
    expect_equal(rowData(cur_spe)$ilastik, cur_panel$ilastik)
    expect_equal(rowData(cur_spe)$Tube.Number, cur_panel$`Tube Number`)
    
    expect_equal(length(colPairs(cur_spe)), 0)
    
    cur_sce <- read_steinbock(path, return_as = "sce", graphs_folder = NULL)
    
    expect_s4_class(cur_sce, "SingleCellExperiment")
    
    expect_equal(rownames(cur_sce), c("Ag107", "Cytokeratin 5", "Laminin", 
                                      "YBX1", "H3K27Ac"))
    expect_equal(assayNames(cur_sce), "counts")
    expect_equal(dim(cur_sce), c(5, 404))
    expect_equal(names(rowData(cur_sce)), 
                 c("channel", "name", "keep", "ilastik", "deepcell", "cellpose", "Tube.Number"))
    expect_equal(names(colData(cur_sce)), c("sample_id", "ObjectNumber", "Pos_X", 
                                            "Pos_Y", "area", 
                                            "axis_major_length", 
                                            "axis_minor_length", "eccentricity",
                                            "width_px", "height_px"))
    
    cur_files <- list.files(file.path(path, "intensities"), full.names = TRUE)
    cur_counts <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_counts <- do.call("rbind", cur_counts)
    
    test1 <- counts(cur_sce)
    colnames(test1) <- NULL
    
    expect_equal(test1, t(cur_counts[,-1]))
    
    cur_files <- list.files(file.path(path, "regionprops"), full.names = TRUE)
    cur_morph <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_morph <- do.call("rbind", cur_morph)
    
    expect_equal(cur_sce$area, cur_morph$area)
    expect_equal(cur_sce$axis_major_length, cur_morph$axis_major_length)
    expect_equal(cur_sce$axis_minor_length, cur_morph$axis_minor_length)
    expect_equal(cur_sce$eccentricity, cur_morph$eccentricity)
    expect_equal(as.numeric(cur_sce$Pos_X), cur_morph$`centroid-1`)
    expect_equal(as.numeric(cur_sce$Pos_Y), cur_morph$`centroid-0`)
    
    cur_panel <- readr::read_csv(file.path(path, "panel.csv"), show_col_types = FALSE)
    expect_equal(rowData(cur_sce)$name, cur_panel$name)
    expect_equal(rowData(cur_sce)$channel, cur_panel$channel)
    expect_equal(rowData(cur_sce)$keep, cur_panel$keep)
    expect_equal(rowData(cur_sce)$deepcell, cur_panel$deepcell)
    expect_equal(rowData(cur_sce)$ilastik, cur_panel$ilastik)
    expect_equal(rowData(cur_sce)$Tube.Number, cur_panel$`Tube Number`)
    
    expect_equal(length(colPairs(cur_sce)), 0)
    
    cur_spe <- read_steinbock(path, graphs_folder = NULL, regionprops_folder = NULL)
    
    expect_equal(rownames(cur_spe), c("Ag107", "Cytokeratin 5", "Laminin", 
                                      "YBX1", "H3K27Ac"))
    expect_equal(assayNames(cur_spe), "counts")
    expect_equal(dim(cur_spe), c(5, 404))
    expect_equal(names(rowData(cur_spe)), 
                 c("channel", "name", "keep", "ilastik", "deepcell", "cellpose", "Tube.Number"))
    expect_equal(names(colData(cur_spe)), c("sample_id", "ObjectNumber",
                                            "width_px", "height_px"))
    expect_null(spatialCoordsNames(cur_spe))
    
    cur_files <- list.files(file.path(path, "intensities"), full.names = TRUE)
    cur_counts <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_counts <- do.call("rbind", cur_counts)
    
    test1 <- counts(cur_spe)
    colnames(test1) <- NULL
    
    expect_equal(test1, t(cur_counts[,-1]))
    
    expect_equal(cur_spe$ObjectNumber, cur_counts$Object)
    
    cur_test <- unique(colData(cur_spe)[,c("sample_id", "width_px", "height_px")])
    
    expect_equal(sub(".tiff$", "", cur_images$image), cur_test$sample_id)
    expect_equal(sub(".tiff$", "", cur_images$image), cur_test$sample_id)
    expect_equal(cur_images$width_px, cur_test$width_px)
    expect_equal(cur_images$height_px, cur_test$height_px)
    
    cur_panel <- readr::read_csv(file.path(path, "panel.csv"), show_col_types = FALSE)
    expect_equal(rowData(cur_spe)$name, cur_panel$name)
    expect_equal(rowData(cur_spe)$channel, cur_panel$channel)
    expect_equal(rowData(cur_spe)$keep, cur_panel$keep)
    expect_equal(rowData(cur_spe)$deepcell, cur_panel$deepcell)
    expect_equal(rowData(cur_spe)$ilastik, cur_panel$ilastik)
    expect_equal(rowData(cur_spe)$Tube.Number, cur_panel$`Tube Number`)
    
    expect_equal(length(colPairs(cur_spe)), 0)
    
    cur_sce <- read_steinbock(path, return_as = "sce", graphs_folder = NULL, regionprops_folder = NULL)
    
    expect_s4_class(cur_sce, "SingleCellExperiment")
    
    expect_equal(rownames(cur_sce), c("Ag107", "Cytokeratin 5", "Laminin", 
                                      "YBX1", "H3K27Ac"))
    expect_equal(assayNames(cur_sce), "counts")
    expect_equal(dim(cur_sce), c(5, 404))
    expect_equal(names(rowData(cur_sce)), 
                 c("channel", "name", "keep", "ilastik", "deepcell", "cellpose", "Tube.Number"))
    expect_equal(names(colData(cur_sce)), c("sample_id", "ObjectNumber",
                                            "width_px", "height_px"))
    
    cur_files <- list.files(file.path(path, "intensities"), full.names = TRUE)
    cur_counts <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_counts <- do.call("rbind", cur_counts)
    
    test1 <- counts(cur_sce)
    colnames(test1) <- NULL
    
    expect_equal(test1, t(cur_counts[,-1]))
    
    cur_panel <- readr::read_csv(file.path(path, "panel.csv"), show_col_types = FALSE)
    expect_equal(rowData(cur_sce)$name, cur_panel$name)
    expect_equal(rowData(cur_sce)$channel, cur_panel$channel)
    expect_equal(rowData(cur_sce)$keep, cur_panel$keep)
    expect_equal(rowData(cur_sce)$ilastik, cur_panel$ilastik)
    expect_equal(rowData(cur_sce)$deepcell, cur_panel$deepcell)
    expect_equal(rowData(cur_sce)$Tube.Number, cur_panel$`Tube Number`)
    
    expect_equal(length(colPairs(cur_sce)), 0)
    
    cur_spe <- read_steinbock(path, pattern = "mockData2")
    
    expect_equal(colnames(cur_spe), paste0(cur_spe$sample_id, "_", cur_spe$ObjectNumber))
    
    expect_s4_class(cur_spe, "SpatialExperiment")
    
    expect_equal(rownames(cur_spe), c("Ag107", "Cytokeratin 5", "Laminin", 
                                      "YBX1", "H3K27Ac"))
    expect_equal(assayNames(cur_spe), "counts")
    expect_equal(dim(cur_spe), c(5, 106))
    expect_equal(names(rowData(cur_spe)), 
                 c("channel", "name", "keep", "ilastik", "deepcell", "cellpose", "Tube.Number"))
    expect_equal(names(colData(cur_spe)), c("sample_id", "ObjectNumber", "area", 
                                            "axis_major_length", 
                                            "axis_minor_length", "eccentricity",
                                            "width_px", "height_px"))
    expect_equal(spatialCoordsNames(cur_spe), c("Pos_X", "Pos_Y"))
    
    cur_files <- list.files(file.path(path, "intensities"), full.names = TRUE, pattern = "mockData2")
    cur_counts <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_counts <- do.call("rbind", cur_counts)
    
    test1 <- counts(cur_spe)
    colnames(test1) <- NULL
    
    expect_equal(test1, t(cur_counts[,-1]))
    
    expect_equal(counts(cur_spe)[1:10], c(0.399655099572807, 0.0344827586206896, 4.64201253035973, 6.50705560733532, 
                                          3.57779644892133, 0.428760413080454, 0.0945868939161301, 1.56471130624413, 
                                          8.0167475938797, 1.46797196567059))
    
    cur_files <- list.files(file.path(path, "regionprops"), full.names = TRUE, pattern = "mockData2")
    cur_morph <- lapply(cur_files, readr::read_csv, show_col_types = FALSE)
    cur_morph <- do.call("rbind", cur_morph)
    
    expect_equal(cur_spe$area, cur_morph$area)
    expect_equal(cur_spe$axis_major_length, cur_morph$axis_major_length)
    expect_equal(cur_spe$axis_minor_length, cur_morph$axis_minor_length)
    expect_equal(cur_spe$eccentricity, cur_morph$eccentricity)
    expect_equal(as.numeric(spatialCoords(cur_spe)[,1]), cur_morph$`centroid-1`)
    expect_equal(as.numeric(spatialCoords(cur_spe)[,2]), cur_morph$`centroid-0`)
    
    cur_panel <- readr::read_csv(file.path(path, "panel.csv"))
    expect_equal(rowData(cur_spe)$name, cur_panel$name)
    expect_equal(rowData(cur_spe)$channel, cur_panel$channel)
    expect_equal(rowData(cur_spe)$keep, cur_panel$keep)
    expect_equal(rowData(cur_spe)$deepcell, cur_panel$deepcell)
    expect_equal(rowData(cur_spe)$ilastik, cur_panel$ilastik)
    expect_equal(rowData(cur_spe)$Tube.Number, cur_panel$`Tube Number`)
    
    expect_equal(colPairNames(cur_spe), "neighborhood")
    
    for (i in unique(cur_spe$sample_id)) {
        cur_dat <- cur_spe[,cur_spe$sample_id == i]
        
        cur_test <- readr::read_csv(file.path(path, "neighbors", paste0(i, ".csv")), show_col_types = FALSE)
        
        expect_equal(cur_test$Object, from(colPair(cur_dat, "neighborhood")))
        expect_equal(cur_test$Neighbor, to(colPair(cur_dat, "neighborhood")))
    }
    
    cur_test <- unique(colData(cur_spe)[,c("sample_id", "width_px", "height_px")])
    
    cur_images_2 <- cur_images[grepl("mockData2", cur_images$image),]
    
    expect_equal(sub(".tiff$", "", cur_images_2$image), cur_test$sample_id)
    expect_equal(sub(".tiff$", "", cur_images_2$image), cur_test$sample_id)
    expect_equal(cur_images_2$width_px, cur_test$width_px)
    expect_equal(cur_images_2$height_px, cur_test$height_px)
    
    cur_sce <- read_steinbock(path, pattern = "mockData2", return_as = "sce")
    
    expect_s4_class(cur_sce, "SingleCellExperiment")
    
    expect_equal(rownames(cur_sce), c("Ag107", "Cytokeratin 5", "Laminin", 
                                      "YBX1", "H3K27Ac"))
    expect_equal(assayNames(cur_sce), "counts")
    expect_equal(dim(cur_sce), c(5, 106))
    expect_equal(names(rowData(cur_sce)), 
                 c("channel", "name", "keep", "ilastik", "deepcell", "cellpose", "Tube.Number"))
    expect_equal(names(colData(cur_sce)), c("sample_id", "ObjectNumber", "Pos_X", 
                                            "Pos_Y", "area", 
                                            "axis_major_length", 
                                            "axis_minor_length", "eccentricity",
                                            "width_px", "height_px"))
    
    cur_files <- list.files(file.path(path, "intensities"), full.names = TRUE, pattern = "mockData2")
    cur_counts <- lapply(cur_files, readr::read_csv)
    cur_counts <- do.call("rbind", cur_counts)
    
    test1 <- counts(cur_sce)
    colnames(test1) <- NULL
    
    expect_equal(test1, t(cur_counts[,-1]))
    
    cur_files <- list.files(file.path(path, "regionprops"), full.names = TRUE, pattern = "mockData2")
    cur_morph <- lapply(cur_files, readr::read_csv)
    cur_morph <- do.call("rbind", cur_morph)
    
    expect_equal(cur_sce$area, cur_morph$area)
    expect_equal(cur_sce$axis_major_length, cur_morph$axis_major_length)
    expect_equal(cur_sce$axis_minor_length, cur_morph$axis_minor_length)
    expect_equal(cur_sce$eccentricity, cur_morph$eccentricity)
    expect_equal(as.numeric(cur_sce$Pos_X), cur_morph$`centroid-1`)
    expect_equal(as.numeric(cur_sce$Pos_Y), cur_morph$`centroid-0`)
    
    cur_panel <- readr::read_csv(file.path(path, "panel.csv"))
    expect_equal(rowData(cur_sce)$name, cur_panel$name)
    expect_equal(rowData(cur_sce)$channel, cur_panel$channel)
    expect_equal(rowData(cur_sce)$keep, cur_panel$keep)
    expect_equal(rowData(cur_sce)$deepcell, cur_panel$deepcell)
    expect_equal(rowData(cur_sce)$ilastik, cur_panel$ilastik)
    expect_equal(rowData(cur_sce)$Tube.Number, cur_panel$`Tube Number`)
    
    expect_equal(colPairNames(cur_sce), "neighborhood")
    
    expect_silent(cur_graphs <- colPair(cur_sce, "neighborhood"))

    for (i in unique(cur_sce$sample_id)) {
        cur_dat <- cur_sce[,cur_sce$sample_id == i]
        
        cur_test <- readr::read_csv(file.path(path, "neighbors", paste0(i, ".csv")), show_col_types = FALSE)
        
        expect_equal(cur_test$Object, from(colPair(cur_dat, "neighborhood")))
        expect_equal(cur_test$Neighbor, to(colPair(cur_dat, "neighborhood")))
    }
    
    cur_test <- unique(colData(cur_sce)[,c("sample_id", "width_px", "height_px")])
    
    expect_equal(sub(".tiff$", "", cur_images_2$image), cur_test$sample_id)
    expect_equal(sub(".tiff$", "", cur_images_2$image), cur_test$sample_id)
    expect_equal(cur_images_2$width_px, cur_test$width_px)
    expect_equal(cur_images_2$height_px, cur_test$height_px)
    
    cur_spe <- read_steinbock(path, panel = NULL)
    
    expect_equal(length(rowData(cur_spe)), 0)
    
    cur_sce <- read_steinbock(path, panel = NULL, return_as = "sce")
    
    expect_equal(length(rowData(cur_sce)), 0)
    
    cur_spe <- read_steinbock(path, extract_coords_from = c("area", "axis_major_length"))
    
    expect_equal(names(colData(cur_spe)), c("sample_id", "ObjectNumber", "centroid.0",
                                            "centroid.1", "axis_minor_length", "eccentricity",
                                            "width_px", "height_px"))
    expect_equal(spatialCoordsNames(cur_spe), c("Pos_X", "Pos_Y"))
    
    cur_files <- list.files(file.path(path, "regionprops"), full.names = TRUE)
    cur_morph <- lapply(cur_files, readr::read_csv)
    cur_morph <- do.call("rbind", cur_morph)
    
    expect_equal(cur_spe$`centroid.1`, cur_morph$`centroid-1`)
    expect_equal(cur_spe$`centroid.0`, cur_morph$`centroid-0`)
    expect_equal(cur_spe$axis_minor_length, cur_morph$axis_minor_length)
    expect_equal(cur_spe$eccentricity, cur_morph$eccentricity)
    expect_equal(as.numeric(spatialCoords(cur_spe)[,1]), cur_morph$area)
    expect_equal(as.numeric(spatialCoords(cur_spe)[,2]), cur_morph$axis_major_length)
    
    cur_sce <- read_steinbock(path, return_as = "sce", extract_coords_from = c("area", "axis_major_length"))
    
    expect_equal(names(colData(cur_sce)), c("sample_id", "ObjectNumber", "Pos_X", "Pos_Y", "centroid.0",
                                            "centroid.1", "axis_minor_length", "eccentricity",
                                            "width_px", "height_px"))
    
    cur_files <- list.files(file.path(path, "regionprops"), full.names = TRUE)
    cur_morph <- lapply(cur_files, readr::read_csv)
    cur_morph <- do.call("rbind", cur_morph)
    
    expect_equal(cur_sce$`centroid.0`, cur_morph$`centroid-0`)
    expect_equal(cur_sce$`centroid.1`, cur_morph$`centroid-1`)
    expect_equal(cur_sce$axis_minor_length, cur_morph$axis_minor_length)
    expect_equal(cur_sce$eccentricity, cur_morph$eccentricity)
    expect_equal(as.numeric(cur_sce$Pos_X), cur_morph$area)
    expect_equal(as.numeric(cur_sce$Pos_Y), cur_morph$axis_major_length)
    
    # This test doesn't make sense anymore
    #cur_spe <- read_steinbock(path, extract_names_from = "channel")
    
    #expect_true(all(is.na(rowData(cur_spe)["Laminin",])))
    #expect_equal(as.character(as.matrix(rowData(cur_spe)["Ag107",])), 
    #             c("Ag107", "Ag107", "1", "1", NA, NA))  
    
    cur_spe <- read_steinbock(path, image_file = NULL)
    
    expect_equal(names(colData(cur_spe)), c("sample_id", "ObjectNumber", "area", 
                                            "axis_major_length", "axis_minor_length", "eccentricity"))
    
    cur_sce <- read_steinbock(path, image_file = NULL, return_as = "sce")
    
    expect_equal(names(colData(cur_sce)), c("sample_id", "ObjectNumber", "Pos_X", "Pos_Y", "area", 
                                            "axis_major_length", "axis_minor_length", "eccentricity"))
    
    cur_spe <- read_steinbock(path)
    cur_images_file <- readr::read_csv(file.path(path, "images.csv"), show_col_types = FALSE)
    cur_images_file <- cur_images_file[order(cur_images_file$image, decreasing = FALSE),]
    
    cur_df <- unique(colData(cur_spe)[,c("sample_id", "width_px", "height_px")])
    expect_equal(cur_images_file$image, paste0(cur_df$sample_id, ".tiff"))
    expect_equal(cur_images_file$width_px, cur_df$width_px)
    expect_equal(cur_images_file$height_px, cur_df$height_px)
    
    cur_spe <- read_steinbock(path, extract_imagemetadata_from = c("recovered", "acquisition_description"))
    
    expect_equal(names(colData(cur_spe)), c("sample_id", "ObjectNumber", "area", 
                                            "axis_major_length", "axis_minor_length", 
                                            "eccentricity", "recovered", "acquisition_description"))
    
    cur_df <- unique(colData(cur_spe)[,c("sample_id", "recovered", "acquisition_description")])
    expect_equal(cur_images_file$image, paste0(cur_df$sample_id, ".tiff"))
    expect_equal(cur_images_file$recovered, cur_df$recovered)
    expect_equal(cur_images_file$acquisition_description, cur_df$acquisition_description)
    
    
    # Parallelisation
    #cur_spe <- read_steinbock(path, BPPARAM = BiocParallel::bpparam())
    
    # Error
    expect_error(cur_spe <- read_steinbock(path = "test"),
                 "'path' doesn't exist.", 
                 fixed = TRUE) 
    expect_error(cur_spe <- read_steinbock(path = c("test", "test2")),
                 "'path' must be a single string.", 
                 fixed = TRUE) 
    expect_error(cur_spe <- read_steinbock(path = 1),
                 "'path' must be a single string.", 
                 fixed = TRUE) 
    
    expect_error(cur_spe <- read_steinbock(path, intensities_folder = NULL),
                 "'intensities_folder' must be specified.", 
                 fixed = TRUE)
    expect_error(cur_spe <- read_steinbock(path, intensities_folder = "test"),
                 "'intensities_folder' doesn't exist.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, intensities_folder = c("test", "test2")),
                 "'intensities_folder' must be a single string.", 
                 fixed = TRUE)
    expect_error(cur_spe <- read_steinbock(path, intensities_folder = 1),
                 "'intensities_folder' must be a single string.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, regionprops_folder = "test"),
                 "'regionprops_folder' doesn't exist.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, regionprops_folder = c("test", "test2")),
                 "'regionprops_folder' must be a single string.", 
                 fixed = TRUE)
    expect_error(cur_spe <- read_steinbock(path, regionprops_folder = 1),
                 "'regionprops_folder' must be a single string.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, graphs_folder = "test"),
                 "'graphs_folder' doesn't exist.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, graphs_folder = c("test", "test2")),
                 "'graphs_folder' must be a single string.", 
                 fixed = TRUE)
    expect_error(cur_spe <- read_steinbock(path, graphs_folder = 1),
                 "'graphs_folder' must be a single string.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, pattern = "test"),
                 "No files were read in.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, extract_cellid_from = "test"),
                 "'extract_cellid_from' not in intensities files.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, extract_cellid_from = c("test", "test2")),
                 "'extract_cellid_from' must be a single string.", 
                 fixed = TRUE)
    expect_error(cur_spe <- read_steinbock(path, extract_cellid_from = 1),
                 "'extract_cellid_from' must be a single string.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, extract_coords_from =  "test"),
                 "'coords' not in regionprops files.", 
                 fixed = TRUE)
    expect_silent(cur_spe <- read_steinbock(path, extract_coords_from =  "test", regionprops_folder = NULL))
    
    expect_error(cur_spe <- read_steinbock(path, extract_coords_from =  1),
                 "'extract_coords_from' must be characters.", 
                 fixed = TRUE)
    
    expect_warning(cur_spe <- read_steinbock(path, panel = "test"),
                   "'panel_file' does not exist.", 
                   fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, panel = c("test", "test2")),
                 "'panel_file' must be a single string.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, panel = 1),
                 "'panel_file' must be a single string.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, extract_names_from = "test"),
                 "'extract_names_from' not in panel file.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, extract_names_from = c("test", "test2")),
                 "'extract_names_from' must be a single string.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, extract_names_from = 1),
                 "'extract_names_from' must be a single string.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, image_file = 1),
                 "'image_file' must be a single string.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, image_file = "test"),
                 "'image_file' doesn't exist.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, extract_imagemetadata_from = 1),
                 "'extract_imagemetadata_from' should only contain characters.", 
                 fixed = TRUE)
    
    expect_error(cur_spe <- read_steinbock(path, extract_imagemetadata_from = c(1, "test")),
                 "'extract_imagemetadata_from' not in images file.", 
                 fixed = TRUE)
})

test_that("read_steinbock function works when files are missing", {
    skip_on_os(os = "windows")
    path <- system.file("extdata/mockData/steinbock", package = "imcRtools")
    
    # Move files to tmp location
    cur_path <- tempdir()
    file.copy(path, cur_path, recursive = TRUE)
    
    # Remove regionprobs folder
    file.remove(list.files(paste0(cur_path, "/steinbock/regionprops"), 
                           full.names = TRUE))
    
    expect_error(cur_spe <- read_steinbock(paste0(cur_path, "/steinbock/")),
                            "File names in 'intensities' and 'regionprops' do not match.", 
                            fixed = TRUE)
    

    # Remove graphs folder
    file.remove(list.files(paste0(cur_path, "/steinbock/neighbors"), 
                           full.names = TRUE))
    
    expect_error(cur_spe <- read_steinbock(paste0(cur_path, "/steinbock/")),
                 "File names in 'intensities' and 'neighbors' do not match.", 
                 fixed = TRUE)

})
