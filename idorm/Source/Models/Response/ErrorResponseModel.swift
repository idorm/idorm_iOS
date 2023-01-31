//
//  ErrorResponseModel.swift
//  idorm
//
//  Created by 김응철 on 2022/12/13.
//

import Foundation

struct ErrorResponseModel: Codable {
  
  enum ErrorCode: String, Codable {
    /**
     400 BAD_REQUEST
     */
    
    /// 입력은 필수입니다.
    case FIELD_REQUIRED
    /// 파일 사이즈 초과 입니다.
    case FILE_SIZE_EXCEEDED
    
    /// 올바른 형식의 이메일이 아닙니다.
    case EMAIL_FORMAT_INVALID
    /// 올바른 형식의 비밀번호가 아닙니다.
    case PASSWORD_FORMAT_INVALID
    /// 올바른 형식의 닉네임이 아닙니다.
    case NICKNAME_FORMAT_INVALID
    /// 올바른 형식의 기숙사 분류가 아닙니다.
    case DORM_CATEGORY_FORMAT_INVALID
    /// 올바른 형식의 입사 기간이 아닙니다.
    case JOIN_PERIOD_FORMAT_INVALID
    
    /// 관리자는 해당 요청의 설정 대상이 될 수 없습니다.
    case ILLEGAL_ARGUMENT_ADMIN
    /// 본인은 해당 요청의 설정 대상이 될 수 없습니다.
    case ILLEGAL_ARGUMENT_SELF
    /// 부모 식별자와 자식 식별자가 같을 수 없습니다.
    case ILLEGAL_ARGUMENT_SAME_PK
    
    /// 매칭 정보가 비공개 입니다.
    case ILLEGAL_STATEMENT_MATCHING_INFO_NON_PUBLIC
    
    /**
     401 UNAUTHORIZED : 인증되지 않은 사용자
     */
    
    /// 올바르지 않은 코드입니다.
    case INVALID_CODE
    /// 이메일 인증 유효시간이 초과되었습니다.
    case EXPIRED_CODE
    /// 로그인이 필요합니다.
    case UNAUTHORIZED_MEMBER
    /// 삭제 권한이 없습니다.
    case UNAUTHORIZED_DELETE
    /// 올바르지 않은 비밀번호 입니다.
    case UNAUTHORIZED_PASSWORD
    
    /**
     403 FORBIDDEN : 권한이 없는 사용자
     */
    
    /// 접근 권한이 없습니다.
    case FORBIDDEN_AUTHORIZATION
    
    /**
     404 NOT_FOUND
     */
    
    /// 등록된 이메일이 없습니다.
    case EMAIL_NOT_FOUND
    /// 등록된 멤버가 없습니다.
    case MEMBER_NOT_FOUND
    /// 등록된 파일이 없습니다.
    case FILE_NOT_FOUND
    /// 등록된 매칭정보가 없습니다.
    case MATCHING_INFO_NOT_FOUND
    /// 등록된 댓글이 없습니다.
    case COMMENT_NOT_FOUND
    /// 멤버가 게시글에 공감하지 않았습니다.
    case POST_LIKED_MEMBER_NOT_FOUND
    /// 등록된 게시글이 없습니다.
    case POST_NOT_FOUND
    /// 등록된 공감이 없습니다.
    case LIKED_NOT_FOUND
    /// 등록된 캘린더 정보가 없습니다.
    case CALENDAR_NOT_FOUND
    
    /**
     409 CONFLICT : Resource의 현재 상태와 충돌, 보통 중복된 데이터 존재
     */
    
    /// 데이터가 이미 존재합니다.
    case DUPLICATE_RESOURCE
    
    /// 이미 등록된 이메일 입니다.
    case DUPLICATE_EMAIL
    /// 이미 등록된 멤버 입니다.
    case DUPLICATE_MEMBER
    /// 이미 등록된 닉네임 입니다.
    case DUPLICATE_NICKNAME
    /// 기존의 닉네임과 같습니다.
    case DUPLICATE_SAME_NICKNAME
    /// 매칭정보가 이미 등록되어 있습니다.
    case DUPLICATE_MATCHING_INFO
    /// 이미 좋아요한 멤버 입니다.
    case DUPLICATE_LIKED_MEMBER
    /// 이미 싫어요한 멤버 입니다.
    case DUPLICATE_DISLIKED_MEMBER
    /// 공감은 한 번만 가능합니다.
    case DUPLICATE_LIKED
    
    /// 닉네임은 30일마다 변경할 수 있습니다.
    case CANNOT_UPDATE_NICKNAME
    /// 본인의 글에 공감할 수 없습니다.
    case CANNOT_LIKED_SELF
    
    /**
     500 INTERNAL_SERVER_ERROR : 서버 에러
     */
    
    /// 서버 에러가 발생했습니다.
    case INTERNAL_SERVER_ERROR
  }
  
  let error: String
  let code: ErrorCode
  let message: String
}

