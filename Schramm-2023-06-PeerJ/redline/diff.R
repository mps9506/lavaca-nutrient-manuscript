library(latexdiffr)
library(fs)


file_1 <- fs::path_wd("Schramm-2023-06-PeerJ/Schramm-2023-06-PeerJ.tex")
file_2 <- fs::path_wd("Schramm-2023-06-PeerJ/Schramm-2023-08-PeerJ.tex")

latexdiff(file_1, file_2, output = "Schramm-2023-06-PeerJ/diff", 
          compile = FALSE
          )
# tinytex::latexmk(fs::path_wd("Schramm-2023-06-PeerJ/diff.tex"), 
#                  engine = "pdflatex",
#                  bib_engine = "biber",
#                  pdf_file = fs::path_wd("Schramm-2023-06-PeerJ/diff.pdf"))

system2(command = "latexmk",
        args = c("-pdf", "-cd Schramm-2023-06-PeerJ/diff.tex"))
