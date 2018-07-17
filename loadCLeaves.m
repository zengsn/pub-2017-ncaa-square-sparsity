% loadCLeaves.m
% Caltech Leaves

dbName = 'CLeaves';
pathPrefix='../../datasets/caltech_leaves/';
firstSample=imread('../../datasets/caltech_leaves/image_0001.jpg');
halfSample =imresize(firstSample,0.5); % ѹ����С
[row col]=size(rgb2gray(halfSample));
numOfSamples=10;
numOfClasses=0; % ��Ҫ�����ݽ��д���

% ��ȡ��ע��¼
labelFile = [pathPrefix 'labels.txt']; % �������
fid = fopen(labelFile);
labelData = textscan(fid, '%d %d', 'delimiter', ',');
fclose(fid);
[numOfLines, two] = size(labelData{1});

for lii=1:numOfLines % ����ÿһ��
    num1=labelData{1}(lii);
    num2=labelData{2}(lii);
    numOfClassSamples = num2-num1+1;
    if numOfClassSamples>numOfSamples % ���㹻������
        numOfClasses = numOfClasses+1; % �ҵ�һ���ϸ����
        classLabels(numOfClasses)=num1;% ��¼��ĵ�һ������λ�� 
    end
end

for cc=1:numOfClasses
    numOfFirst = classLabels(cc);
    for ss=1:numOfSamples        
        path=[pathPrefix 'image_' num2str(numOfFirst+ss-1, '%04d') '.jpg'];
        colored=imread(path);
        halfSample =imresize(colored,0.5); % ѹ����С
        grayed = rgb2gray(halfSample);
        columniation = reshape(grayed, row*col, 1);
        index = (cc-1)*numOfSamples + ss;
        inputData(:,index)=columniation(:,1);
        inputLabel(index,1) = cc;
    end
end
%inputData=double(inputData); % ���е���������

disp('Data is ready!');