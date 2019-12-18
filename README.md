# gauss-qardl-library
 This repository houses the materials to install and use the [GAUSS quantile cointegration code by Jin Seo Cho](https://web.yonsei.ac.kr/jinseocho/qardl.htm).

## What is GAUSS?
 [**GAUSS**](www.aptech.com) is an easy-to-use data analysis, mathematical and statistical environment based on the powerful, fast and efficient **GAUSS Matrix Programming Language**. [**GAUSS**](www.aptech.com) is a complete analysis environment with the built-in tools you need for estimation, forecasting, simulation, visualization and more.

 ## What is the GAUSS QARDL library?
 The [**GAUSS**](www.aptech.com) **QARDL** library is a collection of [**GAUSS**](www.aptech.com) codes developed by [Jin Seo Cho](https://web.yonsei.ac.kr/jinseocho/qardl.htm). The [raw codes](https://web.yonsei.ac.kr/jinseocho/qardl.htm) provided by Jin Seo Jo have been modified to:
1. Make use of [**GAUSS**](www.aptech.com) structures.
2. Use the internal [quantileFit](https://docs.aptech.com/gauss/CR-quantilefit.html) procedure.
3. Include new comments and explanations in the example files.
4. Use up-to-date graphing tools in the example.

>Note: The **QARDL** library no longer requires the QREG library. It uses the internal [quantileFit](https://docs.aptech.com/gauss/CR-quantilefit.html) procedure instead.

 ## Getting Started
 ### Installing
The **GAUSS** **QARDL** library can be easily installed using the [**GAUSS Application Installer**](https://www.aptech.com/support/installation/using-the-applications-installer-wizard/), as shown below:

 1. Download the zipped folder `qardl.zip` from the [QARDL Library Release page](https://github.com/aptech/gauss-qardl/releases/tag/v0.1.0).
 2. Select **Tools > Install Application** from the main **GAUSS** menu.  
 ![install wizard](images/install_application.png)  

 3. Follow the installer prompts, making sure to navigate to the downloaded `qardllib.zip`.
 4. Before using the functions created by `qardl` you will need to load the newly created `qardl` library. This can be done in a number of ways:
   *   Navigate to the **Library Tool Window** and click the small wrench located next to the `qardl` library. Select `Load Library`.  
   ![load library](images/load_carrionlib.jpg)
   *  Enter `library qardl` in the **Program Input/output Window**.
   *  Put the line `library qardl;` at the beginning of your program files.

 >Note: I have provided the individual files found in `qardl.zip` for examination and review. However, installation should always be done using the [`qardl.zip` from the release page](https://github.com/aptech/gauss-carrion-library/releases) and the [**GAUSS Application Installer**](https://www.aptech.com/support/installation/using-the-applications-installer-wizard/).


 ## Authors
 [Erica Clower](mailto:erica@aptech.com)  
 [Aptech Systems, Inc](https://www.aptech.com/)  
 [![alt text][1.1]][1]
 [![alt text][2.1]][2]
 [![alt text][3.1]][3]

 <!-- links to social media icons -->
 [1.1]: https://www.aptech.com/wp-content/uploads/2019/02/fb.png (Visit Aptech Facebook)
 [2.1]: https://www.aptech.com/wp-content/uploads/2019/02/gh.png (Aptech Github)
 [3.1]: https://www.aptech.com/wp-content/uploads/2019/02/li.png (Find us on LinkedIn)

 <!-- links to your social media accounts -->
 [1]: https://www.facebook.com/GAUSSAptech/
 [2]: https://github.com/aptech
 [3]: https://linkedin.com/in/ericaclower
 <!-- Please don't remove this: Grab your social icons from https://github.com/carlsednaoui/gitsocial -->
