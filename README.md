# corpca
Compressive Online Robust Principal Component Analysis with Multiple Prior Information (CORPCA).

    Version 1.1,  Jan. 24, 2017
    Implementations by Huynh Van Luong, Email: huynh.luong@fau.de,
    Multimedia Communications and Signal Processing, University of Erlangen-Nuremberg.

    Please see the file LICENSE for the full text of the license.

Please cite this publication

    PUBLICATION: Huynh Van Luong, N. Deligiannis, J. Seiler, S. Forchhammer, and A. Kaup, 
            "Incorporating Prior Information in Compressive Online Robust Principal Component Analysis," 
             in e-print, arXiv, Jan. 2017.
             
Solving the problem
<a href="https://www.codecogs.com/eqnedit.php?latex=\dpi{150}&space;\min_{x_{t},v_{t}}\Big\{H(x_{t},v_{t})=\frac{1}{2}\|\mathbf{\Phi}(x_{t}&plus;v_{t})-y_{t}\|^{2}_{2}&space;&plus;\lambda\mu\sum\limits_{j=0}^{J}\beta_{j}\|\mathbf{W}_{j}(x_{t}-z_{j})\|_{1}&plus;&space;\mu\Big\|[B_{t-1}v_{t}]\Big\|_{*}\Big\}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\dpi{150}&space;\min_{x_{t},v_{t}}\Big\{H(x_{t},v_{t})=\frac{1}{2}\|\mathbf{\Phi}(x_{t}&plus;v_{t})-y_{t}\|^{2}_{2}&space;&plus;\lambda\mu\sum\limits_{j=0}^{J}\beta_{j}\|\mathbf{W}_{j}(x_{t}-z_{j})\|_{1}&plus;&space;\mu\Big\|[B_{t-1}v_{t}]\Big\|_{*}\Big\}" title="\min_{x_{t},v_{t}}\Big\{H(x_{t},v_{t})=\frac{1}{2}\|\mathbf{\Phi}(x_{t}+v_{t})-y_{t}\|^{2}_{2} +\lambda\mu\sum\limits_{j=0}^{J}\beta_{j}\|\mathbf{W}_{j}(x_{t}-z_{j})\|_{1}+ \mu\Big\|[B_{t-1}v_{t}]\Big\|_{*}\Big\}" /></a>

Inputs:

    yt - m x 1 vector of observations/data (required input)
    Phi - m x n measurement matrix (required input)
    Ztm1 - n x J the foreground prior: initialized by J previous foregrounds 
    Btm1 - n x d the background prior: could be initialized by d previous backgrounds

Outputs:

    xt, vt - n x 1 estimates of foreground and background
    Zt - n x J the updated foreground prior
    Bt - n x d the updated background prior
