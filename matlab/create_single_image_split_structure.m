%This function takes as input the directory containing the dataset.
%For example if we have 4 categories, say airplanes,faces,motorbikes and
%cars directory structure should be:   ./caltech4
%                                      ./caltech4/airplanes
%                                      ./caltech4/faces
%                                      ./caltech4/motorbikes
%                                      ./caltech4/cars
% This functions creates a random split of the dataset. For each category 
% selects Ntrain training images and min(N-Ntrain,Ntest) test images, where
% N is the amount of images of a given category.
% outputs a structure array with the following fields
%    n_images: 1074
%    classname: 'airplanes'; 
%    files: {1x1074 cell}; cell array with file names withouth path, e.g. img_100.jpg
%    train_id: [1x1074 logical]; Boolean array indicating training files
%    test_id: [1x1074 logical];  Boolean array indicating test files                                   
function data = create_single_image_split_structure(main_dir, image_name)

    category_dirs_path = strcat(main_dir, '/test_set/split_by_class_RGB');
    category_dirs = dir(category_dirs_path);
    %remove '..' and '.' directories
    category_dirs(~cellfun(@isempty, regexp({category_dirs.name}, '\.*')))=[];
    category_dirs(strcmp({category_dirs.name},'split.mat'))=[]; 

    for c = 1:length(category_dirs)
        if isdir(fullfile(category_dirs_path,category_dirs(c).name)) && ~strcmp(category_dirs(c).name,'.') ...
                && ~strcmp(category_dirs(c).name,'..')
            imgdir = dir(fullfile(category_dirs_path,category_dirs(c).name, [image_name]));
            if length(imgdir) == 0
                data(c).n_images = length(imgdir);
                data(c).classname = category_dirs(c).name;
                data(c).files = {};
                data(c).train_id = false;
                data(c).test_id = false;   
            else
                data(c).n_images = length(imgdir);
                data(c).classname = category_dirs(c).name;
                data(c).files = {imgdir(1).name};
                data(c).train_id = false;
                data(c).test_id = true;   
            end 
        end
    end
end
