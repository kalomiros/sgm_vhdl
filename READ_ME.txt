This file describes the artifacts submitted along with the paper titled:
---------------------------------------------------------------------
A Hardware Accelerator for the Semi-Global Matching Stereo Algorithm
---------------------------------------------------------------------
By John Kalomiros, John Vourvoulakis and Stavros Vologiannidis
---------------------------------------------------------------------
Dpt. of Compouters, Informatics and Telecommunications, International Hellnic University, Serres Campus, Greece.

Date: August 9, 2023
This article is ublished in the Journal
ACM Transactions on Reconfigurable Technology and Systems

The submitted artifacts include 
A. The VHDL files which describe our proposed implementation. The file hierarchy is as follows:
1. sgm_stereo_package.vhd (PACKAGE)
2. top_level.vhd (top level entity)
3. intro_block.vhd (the introductory block with BT cost computation)
4. line_buffer.vhd (array cost buffers)
5. sgm_buf_h.vhd (array cost buffers)
6. recursive_path.vhd (current net cost array C(p, d) is added with the array of minima of the previous pixel cost array L)
7. parallel_min_tag.vhd (the main entity for fast minimum calculation)
8. compute_min_L.vhd (computation of the close disparity minima)
9. new12_min_Lr2_64.vhd (computation of the array of the far disparity minima)
10. min2.vhd (a simple computation of the minimum among two cost values)


B. The archived project for Quartus Prime Lite (v. 19.1):
new_sgm_13_final_four_dirs.qar

Further instructions and documentation are included in the files, in the form of comments.

Please address questions and comments to John kalomiros (ikalom@ihu.gr)
