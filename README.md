# CORPCA
Compressive Online Robust Principal Component Analysis with Multiple Prior Information (CORPCA).

    Version 1.1,  Jan. 24, 2017
    Implementations by Huynh Van Luong, Email: huynh.luong@fau.de,
    Multimedia Communications and Signal Processing, University of Erlangen-Nuremberg.
    
    Please see the file LICENSE for the full text of the license.

Please cite this publication

    PUBLICATION: Huynh Van Luong, N. Deligiannis, J. Seiler, S. Forchhammer, and A. Kaup, 
            "Incorporating Prior Information in Compressive Online Robust Principal Component Analysis," 
             in e-print, arXiv, Jan. 2017.
             
**_Solving the problem_**

<img src="https://latex.codecogs.com/svg.latex?\dpi{150}&space;\small&space;\min_{\boldsymbol{x}_{t},\boldsymbol{v}_{t}}\Big\{H(\boldsymbol{x}_{t},\boldsymbol{v}_{t})=\frac{1}{2}\|\mathbf{\Phi}(\boldsymbol{x}_{t}&plus;\boldsymbol{v}_{t})-\boldsymbol{y}_{t}\|^{2}_{2}&space;&plus;\lambda\mu\sum\limits_{j=0}^{J}\beta_{j}\|\mathbf{W}_{j}(\boldsymbol{x}_{t}-\boldsymbol{z}_{j})\|_{1}&plus;&space;\mu\Big\|[\boldsymbol{B}_{t-1}\boldsymbol{v}_{t}]\Big\|_{*}\Big\}" title="\small \min_{\boldsymbol{x}_{t},\boldsymbol{v}_{t}}\Big\{H(\boldsymbol{x}_{t},\boldsymbol{v}_{t})=\frac{1}{2}\|\mathbf{\Phi}(\boldsymbol{x}_{t}+\boldsymbol{v}_{t})-\boldsymbol{y}_{t}\|^{2}_{2} +\lambda\mu\sum\limits_{j=0}^{J}\beta_{j}\|\mathbf{W}_{j}(\boldsymbol{x}_{t}-\boldsymbol{z}_{j})\|_{1}+ \mu\Big\|[\boldsymbol{B}_{t-1}\boldsymbol{v}_{t}]\Big\|_{*}\Big\}" /></a>

Inputs:
- <img src="https://latex.codecogs.com/svg.latex?\dpi{150}&space;\boldsymbol{y}_{t}\in&space;\mathbb{R}^{m}" title="\boldsymbol{y}_{t}\in \mathbb{R}^{m}" />: A vector of observations/data <br /> 
- <img src="https://latex.codecogs.com/svg.latex?\dpi{150}&space;\mathbf{\Phi}\in&space;\mathbb{R}^{m\times&space;n}" title="\mathbf{\Phi}\in \mathbb{R}^{m\times n}" />: A measurement matrix <br />
- <img src="https://latex.codecogs.com/svg.latex?\dpi{150}&space;\boldsymbol{z}_{j}\in&space;\mathbb{R}^{n}" title="\boldsymbol{y}_{t}\in \mathbb{R}^{n}" />: The foreground prior <br />
- <img src="https://latex.codecogs.com/svg.latex?\dpi{150}&space;\boldsymbol{B}_{t-1}\in&space;\mathbb{R}^{n\times&space;d}" title="\boldsymbol{B}_{t-1}\in \mathbb{R}^{n\times d}" />: A matrix of the background prior, which could be initialized by previous backgrounds <br />

Outputs:
- <img src="https://latex.codecogs.com/svg.latex?\dpi{150}&space;\boldsymbol{x}_{t},\boldsymbol{v}_{t}\in\mathbb{R}^{n}" title="\boldsymbol{x}_{t},\boldsymbol{v}_{t}\in\mathbb{R}^{n}" />: Estimates of foreground and background
- <img src="https://latex.codecogs.com/svg.latex?\dpi{150}&space;\boldsymbol{Z}_{t}:=\{\boldsymbol{z}_{j}=\boldsymbol{x}_{t-J&plus;j}\}" title="\boldsymbol{Z}_{t}:=\{\boldsymbol{z}_{j}=\boldsymbol{x}_{t-J+j}\}" />: The updated foreground prior
- <img src="https://latex.codecogs.com/svg.latex?\dpi{150}&space;\boldsymbol{B}_{t}\in&space;\mathbb{R}^{n\times&space;d}" title="\boldsymbol{B}_{t}\in \mathbb{R}^{n\times d}" />: The updated background prior

**_Source code files:_** 

**_Experimental results:_** 
