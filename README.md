# Thesis-
MATLAB-based framework integrating structural analysis and machine learning for damage severity classification in 2D frame systems. Damage is modeled via stiffness degradation, with synthetic response data used to train predictive models. (Ongoing work)

##Project Overview

This project explores the integration of structural analysis and machine learning for the classification of damage severity in 2D frame structures.

The main idea is to simulate structural damage through stiffness degradation (reduction of moment of inertia) and analyze how this affects the global structural response. The resulting data are then used to train machine learning models capable of identifying different levels of damage severity.

This work lies at the intersection of structural engineering and data-driven analysis, aiming to demonstrate how synthetic data from numerical simulations can be used for structural health monitoring applications.


##Project Status

This project is currently **under construction**.

The existing implementation includes:

* Structural simulation of a 2D frame
* Synthetic dataset generation
* Initial machine learning pipeline
* Model comparison and evaluation

Further improvements are planned in:

* Feature engineering
* Model tuning and validation
* Structural realism and complexity
* Interpretation of results

##Repository Structure

Thesis/
|
|--src/
|    |--- run_frame_case.m 
|    |--- dataset_column_1.m 
|    |--- ml_model.m 
|    |--- ml_model_comparison.m
|
|---data/ 
|    |---dataset_master.csv 
|
|---results\
|   |--- confusion_matrix.png
|   |--- feature_importance.png
|   |--- data_distribution.png
|   |--- best_model_confusion.png
|   |--- model_accuracy.png
|   |--- cross_validation.png
|   
|--- README.md


##Code Description (src folder)

###run_frame_case.m

This script performs the structural analysis of a 2D frame using the matrix stiffness method.

* Defines geometry, material, and boundary conditions
* Applies loading scenarios (horizontal and distributed loads)
* Solves the system of equations
* Extracts response features such as:

  * Displacements (Ux, Uy)
  * Maximum displacement magnitude
  * Bending moments

These outputs form the basis for dataset creation.

###dataset_column_1.m

This script generates the synthetic dataset.

* Introduces damage by reducing stiffness (moment of inertia)
* Simulates multiple scenarios:

  * Different damage levels (severity)
  * Different members affected
  * Different loading cases
* Stores results into a structured dataset

Output:
➡ `dataset_master.csv`


###ml_model.m

This script implements the initial machine learning pipeline.

* Loads the dataset (`.csv`)
* Selects key structural response features:

  * maxUx, maxUy, maxUmag, maxMoment
* Splits data into training and testing sets
* Trains an ensemble classification model
* Evaluates performance using:

  * Confusion Matrix
  * Accuracy
  * Feature Importance
* Visualizes data distribution


###ml_model_comparison.m

This script extends the analysis by comparing multiple machine learning models.

Models included:

* Ensemble (Bagged Trees)
* KNN
* SVM (ECOC with RBF kernel)
* Naive Bayes

For each model:

* Test accuracy is computed
* Cross-validation is performed
* Performance is compared

The best model is selected and evaluated using a confusion matrix.



##Workflow (Storytelling)

The workflow of the project follows a structured pipeline:

1. **Structural Simulation**
   The frame is analyzed under various loading and damage scenarios using `run_frame_case.m`.

2. **Dataset Generation**
   The script `dataset_column_1.m` runs multiple simulations and generates a dataset containing structural response features.
   This dataset is saved as a `.csv` file.

3. **Machine Learning Analysis**
   The dataset is loaded into `ml_model.m`, where:

   * Features are selected
   * A classification model is trained
   * Initial results are obtained

4. **Model Comparison**
   The dataset is further analyzed using `ml_model_comparison.m`, where multiple algorithms are evaluated to identify the most effective model.

5. **Results & Insights**
   The outputs include:

   * Confusion matrices
   * Feature importance analysis
   * Data distribution plots
   * Model performance comparisons
  


##KeyFindings

* Structural response features can effectively represent damage severity
* The problem exhibits **non-linear behavior**, making SVM models highly effective
* Lateral displacement (maxUx) is the most influential feature
* The best-performing model achieves high classification accuracy (~97%)
* Cross-validation results confirm model stability and generalization


##NOTES

This repository represents an ongoing effort to combine structural mechanics with machine learning techniques.

Future work will focus on:

* Expanding feature sets
* Improving classification robustness
* Applying the methodology to more complex structures


TY :))

