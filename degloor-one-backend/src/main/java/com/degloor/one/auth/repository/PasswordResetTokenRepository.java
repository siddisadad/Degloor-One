package com.degloor.one.auth.repository;

import com.degloor.one.auth.entity.PasswordResetToken;
import com.degloor.one.user.entity.UserAccount;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, UUID> {
    Optional<PasswordResetToken> findByTokenHash(String tokenHash);

    void deleteByUser(UserAccount user);
}
