test_that("detectSpatialContext function works", {
  set.seed(22)
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
  
  ## 1. Cellular neighborhood (CN)
  sce <- buildSpatialGraph(pancreasSCE, img_id = "ImageNb", 
                           type = "knn", 
                           name = "knn_cn_graph", 
                           k = 5)
  
  sce <- aggregateNeighbors(sce, colPairName = "knn_cn_graph", 
                            aggregate_by = "metadata", 
                            count_by = "CellType",
                            name = "aggregatedCellTypes")
  
  cur_cluster <- kmeans(sce$aggregatedCellTypes, centers = 3)
  sce$cellular_neighborhood <- factor(cur_cluster$cluster)
  
  ## 2. Spatial context (SC)
  sce <- buildSpatialGraph(sce, img_id = "ImageNb", 
                           type = "knn", 
                           name = "knn_sc_graph", 
                           k = 15)
  
  sce <- aggregateNeighbors(sce, colPairName = "knn_sc_graph", 
                            aggregate_by = "metadata", 
                            count_by = "cellular_neighborhood",
                            name = "aggregatedNeighborhood")
  
  ## Detect spatial context - tests
  # basics
  expect_silent(cur_sce <- detectSpatialContext(sce, entry = "aggregatedNeighborhood",
                                                threshold = 0.9))
  expect_equal(names(colData(cur_sce)), 
               c("ImageName", "Pos_X", "Pos_Y", "Area", "CellType", "ImageNb",
                 "CellNb", "MaskName", "Pattern", "aggregatedCellTypes","cellular_neighborhood",
                 "aggregatedNeighborhood", "spatial_context"))
  expect_s4_class(cur_sce , class = "SingleCellExperiment") 
  expect_type(cur_sce$spatial_context, "character")
  expect_equal(length(cur_sce$spatial_context), length(cur_sce$cellular_neighborhood))
  
  # check that changing name works 
  expect_silent(cur_sce_2 <- detectSpatialContext(sce, entry = "aggregatedNeighborhood",
                                                  threshold = 0.9, name = "SC"))
  expect_equal(names(colData(cur_sce_2)), 
               c("ImageName", "Pos_X", "Pos_Y", "Area", "CellType", "ImageNb",
                 "CellNb", "MaskName", "Pattern", "aggregatedCellTypes","cellular_neighborhood",
                 "aggregatedNeighborhood", "SC"))
  
  # check that detected spatial_contexts remain the same
  expect_equal(cur_sce$spatial_context[1:10], c("1", "1", "1", "1", "1", "1", "1", "1", "1", "1"))
  
  # change threshold
  expect_silent(cur_sce_3 <- detectSpatialContext(sce, entry = "aggregatedNeighborhood",
                                                  threshold = 0.5))
  expect_false(identical(cur_sce$spatial_context, cur_sce_3$spatial_context))
  
  # aggregatedNeighbors DataFrame contains a row with 0s
  cur_sce_3$aggregatedNeighborhood[1,] <- 0
  expect_silent(cur_sce_4 <- detectSpatialContext(cur_sce_3, entry = "aggregatedNeighborhood",
                                                  threshold = 0.9))
  expect_true(is.na(cur_sce_4$spatial_context[1]))
  
  # aggregatedNeighbors input checks 
  expect_s4_class(sce$aggregatedNeighborhood, "DFrame")
  expect_silent(as.matrix(colData(sce)[,"aggregatedNeighborhood"]))
  
  # aggregatedNeighbors colnames as characters
  cur_sce_5 <- sce
  colnames(cur_sce_5$aggregatedNeighborhood) <- c("B_CN","T_CN","DC_CN")
  expect_silent(cur_sce_5 <- detectSpatialContext(cur_sce_5, entry = "aggregatedNeighborhood",
                                                  threshold = 0.9))
  expect_equal(names(colData(cur_sce_5)), 
               c("ImageName", "Pos_X", "Pos_Y", "Area", "CellType", "ImageNb",
                 "CellNb", "MaskName", "Pattern", "aggregatedCellTypes","cellular_neighborhood",
                 "aggregatedNeighborhood", "spatial_context"))
  expect_equal(cur_sce_5$spatial_context[1:10], 
               c("B.CN", "B.CN", "B.CN", "B.CN", "B.CN", "B.CN", "B.CN", "B.CN", 
                                                  "B.CN", "B.CN"))
  # Errors 
  expect_error(detectSpatialContext(colData(sce)),
               regexp = "'object' needs to be a SingleCellExperiment object.",
               fixed = TRUE)
  
  expect_error(detectSpatialContext(sce, entry = "agregatedNeighbors"),
               regexp = "'entry' not in 'colData(object)'.",
               fixed = TRUE)
  
  sce$aggregatedNeighbors_DF <- as.data.frame(sce$aggregatedNeighborhood)
  expect_error(detectSpatialContext(sce, entry = "aggregatedNeighbors_DF"),
               regexp = "'colData(object)[,entry]' needs to be a DFrame object.",
               fixed = TRUE)
  
  expect_error(detectSpatialContext(sce, entry = "aggregatedNeighborhood", threshold = 1.1),
               regexp = "'threshold' needs to be a single numeric between 0-1.",
               fixed = TRUE)
  
  expect_error(detectSpatialContext(sce, entry = "aggregatedNeighborhood", threshold = "0.9"),
               regexp = "'threshold' needs to be a single numeric between 0-1.",
               fixed = TRUE)
  
  expect_error(detectSpatialContext(sce, entry = "aggregatedNeighborhood", name = c("spatial","context")),
               regexp = "'name' has to be a single character'.",
               fixed = TRUE)
}
)