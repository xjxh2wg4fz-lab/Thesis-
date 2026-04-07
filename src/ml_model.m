clc;
clear;
close all;

%% ================= 1. LOAD DATA =================
% Φορτώνουμε το dataset που δημιουργήσαμε
% Προσοχή στο delimiter (επειδή χρησιμοποιήσαμε ;)

T = readtable('dataset_ml.csv', 'Delimiter',',');

disp('Dataset loaded successfully')
summary(T)

%% ================= 2. FEATURE SELECTION =================
% Επιλέγουμε τα features (inputs του μοντέλου)
% Αυτά είναι τα structural responses

X = T(:, {'maxUx','maxUy','maxUmag','maxMoment'});

% Target variable (τι θέλουμε να προβλέψουμε)
Y = T.severity;

% Μετατροπή σε categorical (απαραίτητο για classification)
Y = categorical(Y);

%% ================= 3. DATA SPLIT =================
% Χωρίζουμε τα δεδομένα σε:
% 80% training
% 20% testing

cv = cvpartition(height(T),'HoldOut',0.2);

X_train = X(training(cv), :);
Y_train = Y(training(cv));

X_test = X(test(cv), :);
Y_test = Y(test(cv));

disp('Data split completed')

%% ================= 4. TRAIN MODEL =================
% Χρησιμοποιούμε ensemble model (Random Forest style)

model = fitcensemble(X_train, Y_train);

disp('Model training completed')

%% ================= 5. PREDICTION =================
% Το μοντέλο προβλέπει τα test δεδομένα

Y_pred = predict(model, X_test);

disp('Prediction completed')

%% ================= 6. ACCURACY =================
% Υπολογισμός ακρίβειας

accuracy = sum(Y_pred == Y_test) / numel(Y_test);

disp(['Accuracy: ', num2str(accuracy)])

%% ================= 7. CONFUSION MATRIX =================
% Δείχνει πόσο καλά προβλέπει κάθε κατηγορία

figure
confusionchart(Y_test, Y_pred)
title('Confusion Matrix - Damage Severity Classification')

%% ================= 8. FEATURE IMPORTANCE =================
% Ποια χαρακτηριστικά επηρεάζουν περισσότερο το μοντέλο

importance = predictorImportance(model);

figure
bar(importance)

xticklabels({'maxUx','maxUy','maxUmag','maxMoment'})
xlabel('Features')
ylabel('Importance')
title('Feature Importance Analysis')

grid on

%% ================= 9. EXTRA VISUALIZATION =================
% Plot για να δούμε τη σχέση δεδομένων

figure
gscatter(T.maxUx, T.maxMoment, T.severity)

xlabel('Max Displacement')
ylabel('Max Moment')
title('Data Distribution: Displacement vs Moment')

grid on

disp('ML pipeline completed successfully')
