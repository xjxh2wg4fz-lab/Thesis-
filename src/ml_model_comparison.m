clc;
clear;
close all;

%% ================= 1. LOAD DATA =================
% Φόρτωση dataset
T = readtable('dataset_ml.csv');

disp('Dataset loaded successfully');
summary(T);

%% ================= 2. TARGET VARIABLE =================
% Μετατρέπουμε το severity σε categorical
Y = categorical(T.severity);

%% ================= 3. FEATURE SELECTION =================
% Βασικά features απόκρισης
% Εδώ βάζουμε περισσότερες μεταβλητές από πριν για να βοηθήσουμε το μοντέλο

X = T(:, { ...
    'maxUx', ...
    'maxUy', ...
    'maxUmag', ...
    'maxMoment', ...
    'M_colL_bottom', ...
    'M_colL_top', ...
    'M_beam_left', ...
    'M_beam_right', ...
    'M_colR_bottom', ...
    'M_colR_top'});

X_array = table2array(X);

%% ================= 4. NORMALIZATION =================
% Κανονικοποίηση features
X_norm = normalize(X_array);

%% ================= 5. TRAIN / TEST SPLIT =================
% 80% training - 20% testing
cv = cvpartition(Y, 'HoldOut', 0.2);

X_train = X_norm(training(cv), :);
Y_train = Y(training(cv));

X_test  = X_norm(test(cv), :);
Y_test  = Y(test(cv));

disp('Data split completed');

%% ================= 6. TRAIN DIFFERENT MODELS =================
% Θα αποθηκεύσουμε accuracy ανά μοντέλο

model_names = {};
test_accuracies = [];
cv_accuracies = [];
trained_models = {};

%% ----- Model 1: Ensemble / Random Forest style -----
mdl1 = fitcensemble(X_train, Y_train, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 150);

pred1 = predict(mdl1, X_test);
acc1 = mean(pred1 == Y_test);

cvmdl1 = crossval(mdl1, 'KFold', 5);
cvacc1 = 1 - kfoldLoss(cvmdl1);

model_names{end+1} = 'Ensemble Bagged Trees';
test_accuracies(end+1) = acc1;
cv_accuracies(end+1) = cvacc1;
trained_models{end+1} = mdl1;

%% ----- Model 2: KNN -----
mdl2 = fitcknn(X_train, Y_train, ...
    'NumNeighbors', 5, ...
    'Distance', 'euclidean', ...
    'Standardize', false);

pred2 = predict(mdl2, X_test);
acc2 = mean(pred2 == Y_test);

cvmdl2 = crossval(mdl2, 'KFold', 5);
cvacc2 = 1 - kfoldLoss(cvmdl2);

model_names{end+1} = 'KNN';
test_accuracies(end+1) = acc2;
cv_accuracies(end+1) = cvacc2;
trained_models{end+1} = mdl2;

%% ----- Model 3: SVM (multiclass μέσω ECOC) -----
template = templateSVM('KernelFunction', 'rbf', 'KernelScale', 'auto');
mdl3 = fitcecoc(X_train, Y_train, 'Learners', template);

pred3 = predict(mdl3, X_test);
acc3 = mean(pred3 == Y_test);

cvmdl3 = crossval(mdl3, 'KFold', 5);
cvacc3 = 1 - kfoldLoss(cvmdl3);

model_names{end+1} = 'SVM (ECOC-RBF)';
test_accuracies(end+1) = acc3;
cv_accuracies(end+1) = cvacc3;
trained_models{end+1} = mdl3;

%% ----- Model 4: Naive Bayes -----
mdl4 = fitcnb(X_train, Y_train);

pred4 = predict(mdl4, X_test);
acc4 = mean(pred4 == Y_test);

cvmdl4 = crossval(mdl4, 'KFold', 5);
cvacc4 = 1 - kfoldLoss(cvmdl4);

model_names{end+1} = 'Naive Bayes';
test_accuracies(end+1) = acc4;
cv_accuracies(end+1) = cvacc4;
trained_models{end+1} = mdl4;

%% ================= 7. RESULTS TABLE =================
Results = table(model_names', test_accuracies', cv_accuracies', ...
    'VariableNames', {'Model', 'TestAccuracy', 'CrossValAccuracy'});

disp('================ MODEL COMPARISON ================');
disp(Results);

%% ================= 8. BEST MODEL SELECTION =================
[~, bestIdx] = max(test_accuracies);
bestModel = trained_models{bestIdx};
bestModelName = model_names{bestIdx};

disp(['Best model based on test accuracy: ', bestModelName]);

%% ================= 9. BEST MODEL PREDICTION =================
Y_pred_best = predict(bestModel, X_test);
best_accuracy = mean(Y_pred_best == Y_test);

disp(['Best model test accuracy: ', num2str(best_accuracy)]);

%% ================= 10. CONFUSION MATRIX =================
figure;
confusionchart(Y_test, Y_pred_best);
title(['Confusion Matrix - Best Model: ', bestModelName]);

%% ================= 11. FEATURE IMPORTANCE =================
% Μόνο για tree-based ensemble βγάζουμε importance εύκολα
if strcmp(bestModelName, 'Ensemble Bagged Trees')
    importance = predictorImportance(bestModel);

    figure;
    bar(importance);
    xticklabels({ ...
        'maxUx','maxUy','maxUmag','maxMoment', ...
        'McolLbot','McolLtop','MbeamL','MbeamR','McolRbot','McolRtop'});
    xtickangle(45);
    ylabel('Importance');
    title('Feature Importance - Best Model');
    grid on;
end

%% ================= 12. VISUAL COMPARISON OF MODELS =================
figure;
bar(test_accuracies);
set(gca, 'XTickLabel', model_names, 'XTickLabelRotation', 30);
ylabel('Test Accuracy');
title('Comparison of Model Accuracy');
grid on;

figure;
bar(cv_accuracies);
set(gca, 'XTickLabel', model_names, 'XTickLabelRotation', 30);
ylabel('Cross-Validation Accuracy');
title('Comparison of Cross-Validation Accuracy');
grid on;
