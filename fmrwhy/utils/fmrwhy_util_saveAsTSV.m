function tsv_fn = fmrwhy_util_saveAsTSV(txt_fn, col_names)

    if ~isempty(txt_fn)
        [d, fn, ext] = fileparts(txt_fn);
        tsv_fn = fullfile(d, [fn '.tsv']);
        temp_txt_fn = fullfile(d, [fn '_temp.txt']);

        data = load(txt_fn);
        data_table = struct(char(col_names(1)), data(:,1), char(col_names(2)), data(:,2), char(col_names(3)), data(:,3), char(col_names(4)), data(:,4), char(col_names(5)), data(:,5), char(col_names(6)), data(:,6));
        %data_table = array2table(data, 'VariableNames', col_names);
        tdfwrite(temp_txt_fn,data_table);
        %writetable(data_table, temp_txt_fn, 'Delimiter', '\t');
        [status, msg, msgID] = movefile(temp_txt_fn, tsv_fn);
    else
    end

