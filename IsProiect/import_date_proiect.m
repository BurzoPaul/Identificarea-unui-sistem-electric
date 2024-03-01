function data = import_date_proiect(~)
    % Specifică numele fișierului CSV
    file_name = 'Burzo.csv';  
    % Importă datele
    data = readmatrix(file_name, 'Range', 'A3:D1002');
end
