% 主文件夹路径
mainFolderPath = '/Volumes/TU280Pro/20240426_SIM/Lattice_hex/';

% 获取主文件夹下的所有一级子文件夹
folders = dir(mainFolderPath);
folders = folders([folders.isdir]);  % 仅保留文件夹

% 创建一个空的tif文件堆栈
tifStack = [];

% 循环遍历每个一级子文件夹
for i = 1:numel(folders)
    folderName = folders(i).name;
    
    % 检查文件夹名是否符合要求
    if startsWith(folderName, 'Lattice_protein_')
        % 构建当前一级子文件夹的完整路径
        currentFolderPath = fullfile(mainFolderPath, folderName);
        
        % 检查是否存在 "WF" 文件夹
        wfFolderPath = fullfile(currentFolderPath, 'Results');
        if exist(wfFolderPath, 'dir')
            % 获取 "WF" 文件夹下的所有.tif文件
            tifFiles = dir(fullfile(wfFolderPath, '*ome_SIM*.tif')); % 仅选择含有"ome_SIM"的tif文件
            
            % 读取并添加.tif文件到堆栈中
            for j = 1:numel(tifFiles)
                tifFileName = fullfile(wfFolderPath, tifFiles(j).name);
                tifData = imread(tifFileName);
                
                % 如果图像不是16位的，则转换为16位
                if ~isinteger(tifData) || ~isequal(class(tifData), 'uint16')
                    disp(['Converting image ', tifFileName, ' to 16-bit']);
                    tifData = uint16(tifData); % 转换为16位
                end
                
                % 添加图像到堆栈中
                tifStack = cat(3, tifStack, tifData);
            end
        end
    end
end

% 检查是否有.tif文件
if isempty(tifStack)
    disp('No TIFF files found.');
else
    % 显示堆栈大小
    disp(['Stack size: ', num2str(size(tifStack))]);
    
    % 保存堆栈为多页tif文件
    outputFilePath = 'stack.tif';
    imwrite(tifStack(:,:,1), outputFilePath, 'tif', 'Compression', 'none');
    for k = 2:size(tifStack, 3)
        imwrite(tifStack(:,:,k), outputFilePath, 'tif', 'WriteMode', 'append', 'Compression', 'none');
    end
    
    disp(['Stack saved as ', outputFilePath]);
end
