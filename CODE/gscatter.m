% GSCATTER   �O���[�v�����ꂽ�ϐ������U�z�}
%
%   GSCATTER(X,Y,G) �́AG �ŃO���[�v�����ꂽ�x�N�g�� X �� Y �̎U�z�}��
%   �쐬���܂��BG �̒��̓����l�����_�Q�́A�����J���[�A�}�[�J�ŕ\�킳��
%   �܂��BG �͕�����̃x�N�g���ł��A�Z���z��ł��A������s��ł��\���܂���B
%   �����āAX �� Y �̍s���́A�������Ȃ���΂Ȃ�܂���B�܂��AG �́A�O���[�v��
%   �ϐ��̒l�̂��ꂼ��ŗL�̌����ɂ���� X ���̒l�� ({G1 G2 G3} �̂悤��) 
%   �O���[�v�����邽�߂ɃO���[�v���ϐ��̃Z���z��Ƃ��Ă��\���܂���B
% 
%   GSCATTER(X,Y,G,CLR,SYM,SIZ) �́A�g�p����J���[�A�}�[�J�A�T�C�Y���w��
%   ���܂��BCLR �́A�J���[�̎d�l��ݒ肷�镶����A�܂��́A�J���[�̎d�l��
%   3 ��̍s��̂����ꂩ�ł��BSYM �́A�}�[�J�̎d�l��ݒ肷�镶����ł��B
%   �ڍׂ́A'help plot' ���Q�Ƃ��Ă��������B���Ƃ��΁ASYM = 'o+x' �̏ꍇ�A
%   �ŏ��̃O���[�v�͉~ (o) �}�[�N�A2 �Ԗڂ̃O���[�v�̓v���X (+) �}�[�N�A
%   3 �Ԗڂ̃O���[�v�̓o�c (x) �}�[�N�ŕ\������܂��BSIZ �́A�v���b�g��
%   �g�p����}�[�J�T�C�Y���w�肵�܂��B�f�t�H���g�ł́A�}�[�J�� '.' �ł��B
% 
%   GSCATTER(X,Y,G,CLR,SYM,SIZ,DOLEG) �́A�}����쐬���邩�ۂ��𐧌䂵�܂��B
%   DOLEG �ɂ́A'on' (�f�t�H���g)�A�܂��́A'off' ���g�p���邱�Ƃ��ł��܂��B
% 
%   GSCATTER(X,Y,G,CLR,SYM,SIZ,DOLEG,XNAM,YNAM) �́AX �� Y �ϐ��̖��O�� 
%   XNAM �� YNAM �Őݒ肵�܂��B���̊e�X�́A����������ł��BXNAM �� YNAM 
%   ���ȗ�����ƁAGSCATTER �́A�n�����ϐ������ŏ��� 2 �Ԗڂ̈����Ƃ���
%   ���肵�悤�Ƃ��܂��B
% 
%   H = GSCATTER(...) �́A�쐬���ꂽ�I�u�W�F�N�g�̃n���h���ԍ�����\��
%   �����z����o�͂��܂��B
%
%   ��:  �����ƂɃR�[�h�����ꂽ�Ԃ̃f�[�^�̎U�z�}��\�����܂��B
%      load carsmall
%      gscatter(Weight, MPG, Origin)
%
%   �Q�l GRPSTATS, GRP2IDX.


%   Copyright 1993-2007 The MathWorks, Inc. 
