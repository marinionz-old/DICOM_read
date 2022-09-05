%% First Part - function call and data retrieval

clc;
clear;

path_im=input('Please introduce image origin path: ','s');
path_final=input('Please introduce image final path: ','s');

[series_num, matrix_size, volume, axial, sagittal, coronal] = DICOM_READ(path_im, path_final);

%% Second Part - output production

% Showing the images under the best tested dynamic range
show_parameters=([1/5,1/100;5/7 4/5]);

for j=1:series_num
    
    % Displaying the information about the 3D volumes
    fprintf('The matrix size for the %dº series (%s) is %d x %d x %d. \n',j, volume(j).series,matrix_size{j}(1),matrix_size{j}(2),matrix_size{j}(3)); 
    fprintf('The %dº 3D structure has a %.2f cm^3 volume. \n \n',j,volume(j).size*(1000^2));
    
    hold on
    
    % Axial
    subplot(2,3,1+(j-1)*3)
    imshow(axial{j},[max(axial{j},[],'all')*show_parameters(1,j) max(axial{j},[],'all')*show_parameters(2,j)]);
    title('Axial view')
    
    % Sagittal
    subplot(2,3,2+(j-1)*3)
    imshow(sagittal{j},[max(sagittal{j},[],'all')*show_parameters(1,j) max(sagittal{j},[],'all')*show_parameters(2,j)]);
    title('Sagittal view')
    
    % Coronal
    subplot(2,3,3+(j-1)*3)
    imshow(coronal{j},[max(coronal{j},[],'all')*show_parameters(1,j) max(coronal{j},[],'all')*show_parameters(2,j)]);
    title('Coronal view')
end