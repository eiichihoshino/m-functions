figure(103)
subplot(4,1,1); plot(ws.data0(:,:,1)-repmat(mean(ws.data0(:,:,1),1), size(ws.data0,1),1));
            xlim([1,size(ws.data0,1)]); title('Original')
subplot(4,1,2); plot((ws.ICA.A*ws.ICA.S)'); xlim([1,size(ws.data0,1)])
             xlim([1,size(ws.data0,1)]); title('Reconstructed')

subplot(4,1,3);
    plot(ws.ICA.S'); xlim([0,size(ws.ICA.S,2)])

    
subplot(4,1,4);
    imagesc(ws.ICA.A',[-0.6,0.6]); colorbar;
    xlabel('Channels')
    ylabel('Components')

    