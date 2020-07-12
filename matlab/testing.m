clearvars data_test desc_test bof_l2lab;

test_image = '3L001880.jpg'; %12
% Create a new dataset split
data_test = create_single_image_split_structure(strcat(basepath, 'img/egocart'), test_image);
% Extract SIFT features from test images
if do_feat_extraction_test  
    extract_sift_features(fullfile(basepath,'img/egocart',test_image),desc_name);    
end
%% Load pre-computed SIFT features for test images 
lasti=1;
for i = 1:length(data_test)
     images_descs = get_descriptors_files(data_test,i,file_ext,desc_name,'test');
     for j = 1:length(images_descs)
        fname = fullfile(basepath,'img/egocart',dataset_dir_test,data_test(i).classname,images_descs{j});
        fprintf('Loading %s \n',fname);
        tmp = load(fname,'-mat');
        tmp.desc.class=i;
        tmp.desc.imgfname=regexprep(fname,['.' desc_name],'.jpg');
        desc_test(lasti)=tmp.desc;
        desc_test(lasti).sift = single(desc_test(lasti).sift);
        lasti=lasti+1;
     end
end
%% K-means descriptor quantization means assignment of each feature

 for i=1:length(desc_test)    
      sift = desc_test(i).sift(:,:); 
      dmat = eucliddist(sift,VC);
      [quantdist,visword] = min(dmat,[],2);
      % save feature labels
      desc_test(i).visword = visword;
      desc_test(i).quantdist = quantdist;
 end
%% Represent each image by the normalized histogram of visual

for i=1:length(desc_test) 
    visword = desc_test(i).visword;
    H = histc(visword,[1:nwords_codebook]);
  
    % normalize bow-hist (L1 norm)
    if norm_bof_hist
        H = H/sum(H);
    end
  
    % save histograms
    desc_test(i).bof=H(:)';
end
%%%%LLC Coding

for i=1:length(desc_test) 
   disp(desc_test(i).imgfname);
   desc_test(i).llc = max(LLC_coding_appr(VC,desc_test(i).sift));
   desc_test(i).llc=desc_test(i).llc/norm(desc_test(i).llc);
end
% Concatenate bof-histograms into a test matrix

bof_test=cat(1,desc_test.bof);
llc_test = cat(1,desc_test.llc);

% Construct label Concatenate bof-histograms into a test matrix 
labels_test=cat(1,desc_test.class);

if do_L2_NN_classification
    % Compute L2 distance between BOFs of test and training images
    bof_l2dist=eucliddist(bof_test,bof_train);
    
    % Nearest neighbor classification (1-NN) using L2 distance
    [mv,mi] = min(bof_l2dist,[],2);
    bof_l2lab = labels_train(mi);
    idxReal = ismember(testSet(:,1), string({test_image}));
    % Access the table for these specific rows
    outReal=testSet(idxReal,:);
   
    [filepath,name,ext] = fileparts(desc_train(mi).imgfname);
    idx = ismember(trainSet(:,1), string({strcat(name,ext)}));
    % Access the table for these specific rows
    out=trainSet(idx,:);
    if bof_l2lab == labels_test
        fprintf("\nCorrect prediction! \n");
    else
        fprintf("\nError \n");
    end
    fprintf("\nPredicted class: %d, Correct class: %d \nPredicted Position: (%d, %d) Actual position: (%d, %d) \n", str2double(string(classes(bof_l2lab))), str2double(string(classes(labels_test))),str2double(string(out(3))), str2double(string(out(4))), str2double(string(outReal(3))), str2double(string(outReal(4))));
    fprintf("Difference in position \nx: %d y: %d \n", (str2double(string(out(3))) - str2double(string(outReal(3)))) ,(str2double(string(out(4))) - str2double(string(outReal(4)))) );
    fprintf("Predicted image : %s \n", desc_train(mi).imgfname);
end
