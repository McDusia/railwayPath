

# Train Route Choice Support System 

This paper describes the Train Route Choice Support System, which is implemented to support designing optimal train route. System is aimed to specialised engineers. Basic functionality of the system are prediction of the price of the area, through which the route will go and presenting this route and also all exceeding the geometrical requirements. System includes application, which enables user to draw train route, checking prices of single parcels and checking geometrical requirements. Therefore system simplify the process of choosing cheap and at the same time permissible trace.   


## Introduction
The main goal of the paper was to create a system that aids in finding new train routes. Designing new sections of train routes is a complex task. This is an \textbf{optimization problem}, where the aim is to find the best solution from all feasible solutions. Similar problems are designing new sections of roads or finding the best path for pipelines. Still, most of these problems are being resolved manually, only with a little support by computer software. The cause of problems being resolved manually is due to the fact that there are \textbf{many factors}\cite{clues_to_optimization} which have an impact on the optimal solution and a lot of them are difficult to take into account in computer software (for instance people, government preferences). Despite this, software, which can improve and automate the process of choosing the optimal solution, even in some part, are desired, because they can significantly reduce costs. In the paper the main focus is on supporting choosing the optimal new section of train route mainly based on information about parcels, which the route will be going through. Train Route Choice Support System gives an estimated price of drawing a specific route and provides extra information with tips for specialised engineers. This therefore aids in choosing the optimal trace. 

There are \textbf{a few solutions on the market}\cite{Ferrovia}\cite{Rail_Simulation}, but they are expensive and there is no possibility to adjust them to customer needs. What is more, all developed solutions do not consider fields' prices and do not optimize their prices. Train Route Choice Support System is designed to reduce costs using information about parcels, which has not been implemented in any available solutions.

## Related Work
\section{Related work}
General approach to support finding new section of railway routes is supply software to visualize routes. For instance Ferrovia provides many options to design geometric of the route. There is multiple options which help to adjust all parameters to enable meet requirements. There is special menu to design turnouts, six types of rail connections both for parallel alignments and non-parallel alignments. Another software, developed by company Anylogic is a system which provide many simulation. These simulations can be used in many industries, for example for simulation new railway roads, railway stations. They can be used to exploration and testing of plans before committing to construction. This software is useful to see how proposed solution will work. Still it does not supply any tips which area should be chose to lead a new railway road. 

Nowadays, implementing system which will propose a few good trace of new sections of railway road is very difficult and complex to do at all. It is caused by many factors, different people's needs and requirements and also geometrical requirements. One proposed solution is to use heuristic algorithm (A*), which is used for example in games or by robots to find the route in environment. Before implementing such solution many data must be collected to make results as useful as possible. It is necessary to collect information as the demand for rail transport in many areas, information about points through which road should be leaded, landform, all geometrical restrictions, kind of train, design speed and parcels' prices. The more information about the best solution we will gather, the better solution we could implement. 

Crucial meaning for the price of the trace route, and as a result, for the optimization of investment, are the prices of the parcels. Generally, the prices of parcels are determined by the specialized appraiser. In his work, he take into account many parameters of the parcel and after deep analysis and basing on their knowledge, they valuate the parcel. It is very expensive and time-consuming process and nobody will pay for valuate all prices in the whole state or country. In Train Route Choice Support System, there is implemented valuation of all parcels in Los Angeles county. This is the first step to implement heuristic algorithm, however even at this stage this knowledge can significantly reduce route costs of new section of train route. Verification of the radius of the curvature of the tracks and the fall in the area are implemented to stand up to competition.

## Problem and Requirements
While designing railway roads designers must take into account many factors. Building railway road is a huge undertaking.  The route must be well thought out to meet the demand and at the same time minimal cost and minimal destruction of the environment.

Sections of railway road is designed to a specific type of train and to specific speed named design speed. Based on these information, there is calculated geometrical requirements. Moreover geometrical restrictions are connected to each other. For instance if the section has large fall in the area, the curvature must be gentle.

### Route Restrictions
Designer of the route must consider below factors:
    - type of train and design speed.
    - maximal fall in the area - it is necessary to consider the design speed of the section and the minimal radius of curvature.
    - minimal radius of curvature (curvature of the road) - depends of the speed and fall in the area.
    - location relative to the station (near station train drive slower).

Furthermore, train route designer must consider facts that:
     - on the trace must be placed units for maintaining equipment,
    - route must consider electrical infrastructure, as close to route as possible to provide the required power,
    - trace must not be routed by water area and places of natural value,
    - trace should be routed in the area, where is demand for train transport,
    - trace must be approved by the office, offices decides if a specified area can be intended for the railway line.

### Previous Approach
Currently designing new section of railway road is manual work of specialised engineers. There is only support of computer software in drawing ready routes on the map. Previously there were not any support in predicting prices of the area under route. The price of single parcels were estimated by appraisers. Such value is precise, but valuating it is costly and last a long time. As a result the prices of parcels are not take into consider while designing railway roads. The estimated prices are using to buy the specified parcel after choosing the course of the route. Whereas sometimes choosing the other, similar route, but through other parcels can significantly reduce costs. Geometrical requirements are meet thanks to engineer knowledge.

## System Description
This paragraph describes Train Route Choice Support System overview and most interesting aspects of system.
### System Overview
% Is the solution of the problem correct and is it presented in 
% a convincing way; is the methodology described?

\begin{figure}[H]
  \centering
  \includegraphics[width=0.55\textwidth]{drawPath.png}
  \caption{This figure shows the usage of Train Route Choice Support System.}
\end{figure}

Train Route Choice Support System (TRCSS) is designed to support process of choosing routes by specialised engineers.
It provide drawing railway path and adjusting it in the runtime (Figure 1). TRCSS includes estimation of each parcel price in Los Angeles County using machine learning techniques. Also systems present all geometrical requirements exceeding in the runtime. Essential capacities of the system are presented in Figure 2.

\begin{figure}[H]
  \centering
  \includegraphics[width=0.75\textwidth]{SchemaBig.png}
  \caption{Flow diagram shows system abilities.}
\end{figure}

### Parcel Prices Prediction
There were used two-phase approach to estimate parcel prices.
Firstly there were implemented classification to three bucket prices (cheap, medium and expensive parcels). Secondly, for each bucket price there were trained neural network model to predict price value of parcels, for which there have not been any data gathered related to their price. Therefore user can check the price of any parcel in the area of Los Angeles County and check the estimated price of the drawn route based on the information of the prices of parcels parts (with given width), through which the route runs. 

### Support Meeting Geometrical Requirements
TRCSS has implemented validation of fall in the area and radius of curvature. To validate fall in the area it has been created a net from points with known height above see level with given accuracy. For these point height is taken from Open Elevation API. Height for rest of the point in the area is estimated using double-line interpolation. To validate radius of curvature it is checked if the radius of the circle described on the triangle built from three succeeding point from the route is longer than the maximal radius given as parameter by user. Thanks to it engineers can adjust geometric parameters of the route. Program presents all exceeded geometrical requirements. 

## Results

### Price Estimation Results

Price estimation results are satisfying. Using two-phase approach (firstly use classification and then regression) led to good accuracy (Figure 3). 

\begin{figure}[H]
\begin{center}
\begin{tabular}{ |c|c|c|c|} 
\hline
Price &  Mean absolute & Mean absolute \\
bucket  &  error [\$] & error [\%] \\
\hline
cheap &   5857.6646 & 2.4121\% \\ 
medium  & 19392.5527 & 2.6547\% \\ 
expensive &  14674.8105 & 0.4017\% \\ 
\hline
\end{tabular}
\end{center}
\caption{Table shows the accuracy the parcel prices estimations for each price bucket for those parcels with data about last sale price.}
\end{figure}

### Meeting Geometrical Requirements Support
The validation of fall in the area is sufficient for estimate what additional adjustments (for instance leveling the area) must be implemented. The validation of the radius of curvature shows user that he must change the route slightly. Listed validations improve specialised engineers work.  

## Used Methods and Tools
To predict parcel prices firstly there were used Weka and Knime programs, which enable to test many algorithms. At the end, most promising algorithms are implemented in Python language, with usage Keras library, which significantly simplify the work, numpy, tensorflow and other. To draw railway path and present results on the map there is used ArcGIS solution. Data is kept in SQL database and at the end, ready results of parcels prices predictions are transfering to ArcGIS server.

## Evaluation
The system was presented to the user. Also some tests were run.

## Conclusions and Future Work
Parcels prices prediction are the first step to automate the process of finding new sections of railway roads, because it delivers data, which are difficult and costly to gather and at the same time necessarily needed to valuate the road. Validation are useful for route designers, because it enable to estimate costs of necessary adjustment. 

In the part of estimation parcel prices possible development:
    - try the other machine learning algorithms,
    - check the accuracy of current trained neural network for parcels, which price is estimated by experts
    - check the accuracy of current trained neural network for database with new data from the next year

It is planned to implement more functionalities in application to present routes:
    - possibility to block some parcel to prevent trace route through it
    - add signs to parcels which informs users about type of the area
    - persistence of routes and user interface to administrating them (add, delete, edit)
    - use other information from database like type of the area to enable exclude routes through airport, highway etc.

## License
![alt text](Train_Route_Choice_Support_System___Article.pdf)
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
