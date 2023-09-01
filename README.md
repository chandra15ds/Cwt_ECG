# Cwt_ECG
continuous wavelet transformation for ECG signal(1D to 2D) using morlet wavelet in VHDL 

In the source folder, we have the cwt.vhd file responsible for processing our data. This data is then passed through cwt.vhd to signal_storage.vhd. In the signal_storage.vhd, we initialize a Block RAM (BRAM) with zero values.

Here's where it gets interesting: for a Morlet wavelet of scale 1, we have a data length of 10. However, to ensure that the size of the output signal after convolution remains consistent at 256, we add zero padding. This means we insert zeros at the beginning (4 zeros) and at the end (5 zeros) of the data.

Similarly, for a Morlet wavelet of scale 2, we have a data length of 20. To maintain the same output signal size of 256, we insert zeros as padding, adding 9 zeros at the beginning and 10 zeros at the end of the data.

After the padding is done, the signal_storage sends blocks of data to the control unit. This control unit manages and sends data to the convolution unit in a repeated fashion until all data sets have been processed.

This ensures that our input data is processed effectively and consistently, and any necessary zero-padding is applied to maintain the desired output signal size of 256.
