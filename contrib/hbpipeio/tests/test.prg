/*
 * Harbour Project source code:
 *    demonstration/test code for PIPEIO
 *
 * Copyright 2015 Przemyslaw Czerpak <druzus / at / priv.onet.pl>
 * www - http://harbour-project.org
 *
 */

#require "hbpipeio"

#include "fileio.ch"

PROCEDURE Main()
   LOCAL pFile, cData, cBuffer, cResult, nLen, nDone

   IF Empty( pFile := hb_vfOpenProcess( "gzip", FO_READWRITE, 1000 ) )
      ? "Cannot open file."
   ELSE

      ? "writting..."
      cData := hb_tsToStr( hb_dateTime() ) + hb_eol() + ;
               Version() + hb_eol() + ;
               OS() + hb_eol() + ;
               replicate( "0123456789" + hb_eol(), 1000 ) + ;
               "END" + hb_eol()
      nDone := 0
      WHILE nDone < hb_BLen( cData ) .AND. ;
            ( nLen := hb_vfWrite( pFile, hb_BSubStr( cData, nDone + 1 ) ) ) > 0
         nDone += nLen
         ? "written: " + hb_ntos( nLen )
      ENDDO
      ? "total bytes written: " + hb_ntos( nDone ) + ;
         ", error: " +  hb_ntos( FError() )
      /* close input stream fro GZIP process to indicate end of data */
      hb_vfConfig( pFile, HB_VF_SHUTDOWN, FO_WRITE )
      ?

      cResult := ""
      ? "reading..."
      cBuffer := Space( 1000 )
      WHILE ( nLen := hb_vfRead( pFile, @cBuffer ) ) > 0
         cResult += left( cBuffer, nLen )
         ? "read: " + hb_ntos( nLen )
      ENDDO
      ? "total bytes read: " + hb_ntos( Len( cResult ) ) + ;
         ", error: " +  hb_ntos( FError() )

      /* close the pipe file and wait for child process termination */
      ? "closing..."
      hb_vfClose( pFile )
      ? "DONE"
      ?

      hb_vfErase( "data.gz" )
      ? "write data.gz " + hb_ntos( len( cResult ) ) + " "
      ?? iif( len( cResult ) == 0, ( hb_vfErase( "data.gz" ), .f. ), ;
                                   hb_memoWrit( "data.gz", cResult ) )
      /* check if we can decode data compressed by GZIP */
      IF hb_ZUncompress( cResult ) == cData
         ? "OK, GZIP output decompressed correctly and much the source"
      ELSE
         ? "ERROR, decompressed GZIP output not much the source"
      ENDIF
   ENDIF
   ?
RETURN