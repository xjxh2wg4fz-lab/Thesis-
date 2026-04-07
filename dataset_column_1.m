clc;
clear;
clear functions;

sample_id = 0;
rows = {};

Fh_cases = [10e3, 15e3, 20e3, 25e3];
q_cases  = [-10e3, -15e3, -20e3];

healthy_vals     = [1.00, 0.995, 0.990, 0.985, 0.980];
slightly_vals    = [0.975, 0.970, 0.965, 0.960, 0.955];
slight_vals      = [0.950, 0.940, 0.930, 0.920, 0.910];
moderate_vals    = [0.900, 0.875, 0.850, 0.825, 0.800];
significant_vals = [0.790, 0.770, 0.750, 0.730, 0.710];
severe_vals      = [0.690, 0.650, 0.600, 0.550, 0.500];

severity_map = {
    'healthy',            healthy_vals;
    'slightly_damaged',   slightly_vals;
    'slight',             slight_vals;
    'moderate',           moderate_vals;
    'significant',        significant_vals;
    'severe',             severe_vals
};

%% ================= Phase A: single-member damage =================
for s = 1:size(severity_map,1)

    severity_name = severity_map{s,1};
    severity_vals = severity_map{s,2};

    for member = 1:3
        for val = severity_vals
            for Fh = Fh_cases
                for q = q_cases

                    I_factors = [1.00, 1.00, 1.00];
                    I_factors(member) = val;

                    % σωστή κλήση function
                    out = run_frame_case(I_factors, Fh, q);

                    sample_id = sample_id + 1;

                    pattern = member_pattern(I_factors);
                    n_damaged_members = sum(abs(I_factors - 1.00) > 1e-12);

                    rows(end+1,:) = { ...
                        sample_id, ...
                        I_factors(1), I_factors(2), I_factors(3), ...
                        pattern, n_damaged_members, severity_name, ...
                        Fh, q, ...
                        out.maxUx, out.maxUy, out.maxUmag, out.maxMoment, ...
                        out.M_colL_bottom, out.M_colL_top, ...
                        out.M_beam_left, out.M_beam_right, ...
                        out.M_colR_bottom, out.M_colR_top ...
                    };

                end
            end
        end
    end
end



%% ================= Phase B: two-member combinations =================
combo_pairs = [1 2; 1 3; 2 3];

for s = 1:size(severity_map,1)

    severity_name = severity_map{s,1};
    severity_vals = severity_map{s,2};

    for p = 1:size(combo_pairs,1)
        m1 = combo_pairs(p,1);
        m2 = combo_pairs(p,2);

        for val1 = severity_vals
            for val2 = severity_vals
                for Fh = Fh_cases
                    for q = q_cases

                        I_factors = [1.00, 1.00, 1.00];
                        I_factors(m1) = val1;
                        I_factors(m2) = val2;

                        out = run_frame_case(I_factors, Fh, q);

                        sample_id = sample_id + 1;

                        pattern = member_pattern(I_factors);
                        n_damaged_members = sum(abs(I_factors - 1.00) > 1e-12);

                        rows(end+1,:) = { ...
                            sample_id, ...
                            I_factors(1), I_factors(2), I_factors(3), ...
                            pattern, n_damaged_members, severity_name, ...
                            Fh, q, ...
                            out.maxUx, out.maxUy, out.maxUmag, out.maxMoment, ...
                            out.M_colL_bottom, out.M_colL_top, ...
                            out.M_beam_left, out.M_beam_right, ...
                            out.M_colR_bottom, out.M_colR_top ...
                        };

                    end
                end
            end
        end
    end
end

%% ================= Phase C: three-member combinations =================
for s = 1:size(severity_map,1)

    severity_name = severity_map{s,1};
    severity_vals = severity_map{s,2};

    for val1 = severity_vals
        for val2 = severity_vals
            for val3 = severity_vals
                for Fh = Fh_cases
                    for q = q_cases

                        I_factors = [val1, val2, val3];

                        out = run_frame_case(I_factors, Fh, q);

                        sample_id = sample_id + 1;

                        pattern = member_pattern(I_factors);
                        n_damaged_members = sum(abs(I_factors - 1.00) > 1e-12);

                        rows(end+1,:) = { ...
                            sample_id, ...
                            I_factors(1), I_factors(2), I_factors(3), ...
                            pattern, n_damaged_members, severity_name, ...
                            Fh, q, ...
                            out.maxUx, out.maxUy, out.maxUmag, out.maxMoment, ...
                            out.M_colL_bottom, out.M_colL_top, ...
                            out.M_beam_left, out.M_beam_right, ...
                            out.M_colR_bottom, out.M_colR_top ...
                        };

                    end
                end
            end
        end
    end
end

%% ================= CREATE TABLE =================
disp('Rows created:');
disp(size(rows));

T = cell2table(rows, 'VariableNames', { ...
    'sample_id', ...
    'I1_factor', 'I2_factor', 'I3_factor', ...
    'pattern', 'n_damaged_members', 'severity', ...
    'Fh_total', 'q_beam', ...
    'maxUx', 'maxUy', 'maxUmag', 'maxMoment', ...
    'M_colL_bottom', 'M_colL_top', ...
    'M_beam_left', 'M_beam_right', ...
    'M_colR_bottom', 'M_colR_top'});

writetable(T, 'dataset_master.csv');

disp('Dataset generation complete.');